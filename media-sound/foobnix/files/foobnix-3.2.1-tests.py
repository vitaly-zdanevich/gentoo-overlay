"""Offline regression tests for Foobnix on supported Gentoo Python versions."""

import io
import os
from pathlib import Path
import sys
import tempfile
import time
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch
import wave

import gi

gi.require_version('Gtk', '3.0')
gi.require_version('Gst', '1.0')
from gi.repository import GLib, Gst, Gtk


class CompatibilityTests(unittest.TestCase):
	"""Exercise the replaced APIs with a real GUI and local audio data."""

	def test_download(self):
		"""Save a mocked HTTP response using Python's supported URL opener."""
		from foobnix.dm import dm_dowloader
		from foobnix.util.const import DOWNLOAD_STATUS_COMPLETED

		payload = b'Foobnix download fixture' * 300
		response = io.BytesIO(payload)
		response.headers = {'Content-Length': str(len(payload))}
		opener = Mock()
		opener.open.return_value = response
		with tempfile.TemporaryDirectory() as destination:
			bean = SimpleNamespace(path='https://example.invalid/music.mp3',
				save_to=destination, text='fixture')
			settings = SimpleNamespace(online_save_to_folder=destination)
			with patch.object(dm_dowloader, 'build_opener', return_value=opener), \
					patch.object(dm_dowloader, 'FC', return_value=settings), \
					patch.object(dm_dowloader.time, 'sleep'):
				dm_dowloader.Dowloader(Mock(), bean, Mock()).download()
			opener.open.assert_called_once_with('https://example.invalid/music.mp3')
			self.assertEqual((Path(destination) / 'fixture.mp3').read_bytes(), payload)
			self.assertEqual(bean.status, DOWNLOAD_STATUS_COMPLETED)
			self.assertEqual(bean.persent, 100)

	def test_local_playback(self):
		"""Decode generated PCM audio through Foobnix's GStreamer pipeline."""
		from foobnix.gui.engine.gstreamer import GStreamerEngine

		make_element = Gst.ElementFactory.make

		def make_test_element(factory, name):
			"""Replace only the audio device; retain the real decoding pipeline."""
			if factory == 'autoaudiosink':
				element = make_element('fakesink', name)
				element.set_property('sync', True)
				return element
			return make_element(factory, name)

		with tempfile.TemporaryDirectory() as directory:
			filename = str(Path(directory) / 'sample.wav')
			with wave.open(filename, 'wb') as audio:
				audio.setparams((1, 2, 8000, 8000, 'NONE', 'not compressed'))
				audio.writeframes(b'\x00\x00' * 8000)
			with patch.object(Gst.ElementFactory, 'make', make_test_element):
				engine = GStreamerEngine(Mock())
			finished = Mock()
			engine.notify_eos = finished
			bean = SimpleNamespace(path=filename, start_sec=0, duration_sec=1,
				is_cue_track=False, type=None)
			try:
				engine.play(bean)
				deadline = time.monotonic() + 8
				while not finished.called and time.monotonic() < deadline:
					while GLib.MainContext.default().pending():
						GLib.MainContext.default().iteration(False)
					time.sleep(0.01)
				self.assertTrue(finished.called, 'Local playback did not reach end of stream')
			finally:
				engine.state_stop(show_in_tray=False)
				engine.player.set_state(Gst.State.NULL)

	def test_window_startup(self):
		"""Initialize the complete GTK interface without external requests."""
		from foobnix.gui.foobnix_core import FoobnixCore
		from foobnix.util import analytics
		from foobnix.util.net_wrapper import NetWrapper

		with patch.object(analytics, 'send'), patch.object(NetWrapper, 'start_ping'):
			core = FoobnixCore(with_dbus=False)
			try:
				core.run()
				self.assertTrue(core.main_window.get_visible())
				GLib.timeout_add(100, Gtk.main_quit)
				Gtk.main()
			finally:
				core.dm.on_quit()
				core.media_engine.player.set_state(Gst.State.NULL)
				core.main_window.destroy()
				core.trayicon.hide()


def main():
	"""Isolate legacy home paths and run only suites that need no accounts."""
	upstream = '--upstream' in sys.argv
	original_expanduser = os.path.expanduser
	with tempfile.TemporaryDirectory() as profile:
		def expanduser(path):
			"""Redirect Foobnix settings without changing the caller's home."""
			if path == '~' or path.startswith('~/'):
				return profile + path[1:]
			return original_expanduser(path)

		with patch('os.path.expanduser', expanduser):
			loader = unittest.defaultTestLoader
			suite = loader.loadTestsFromTestCase(CompatibilityTests)
			if upstream:
				from test.test_sorting import Test as SortingTests
				from test.test_text_utils import TestSplitterFunctions

				# Upstream expects Python 2's overflowing int conversion to preserve
				# this input order. Python 3 sorts the arbitrary-size integers.
				SortingTests.test_log_compare = unittest.expectedFailure(
					SortingTests.test_log_compare)
				# Existing upstream bug: a missing width truncates the text to ''.
				TestSplitterFunctions.test_empty_len = unittest.expectedFailure(
					TestSplitterFunctions.test_empty_len)
				suite.addTests(loader.loadTestsFromNames([
					'test.test_sorting', 'test.test_time_utils',
					'test.test_text_utils', 'test.test_version',
				]))
			result = unittest.TextTestRunner(verbosity=2).run(suite)
			return not result.wasSuccessful()


if __name__ == '__main__':
	sys.exit(main())
