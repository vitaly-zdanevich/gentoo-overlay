# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

ELECTRON_PV="41.7.1"

DESCRIPTION="Desktop Git client with a visual commit graph and automation pipelines"
HOMEPAGE="https://github.com/kitarasenka/twig https://kitarasenka.github.io/twig/"
SRC_URI="
	https://github.com/kitarasenka/twig/archive/refs/tags/twig-v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/electron/electron/releases/download/v${ELECTRON_PV}/electron-v${ELECTRON_PV}-linux-x64.zip
"
# BEGIN GENERATED NPM DISTFILES
SRC_URI+="
	https://registry.npmjs.org/@esbuild/linux-x64/-/linux-x64-0.28.2.tgz -> npm-7625c9d2ed9ce82f-linux-x64-0.28.2.tgz
	https://registry.npmjs.org/@eslint-community/eslint-utils/-/eslint-utils-4.10.1.tgz ->
		npm-b3a03daac3779f42-eslint-utils-4.10.1.tgz
	https://registry.npmjs.org/@eslint-community/regexpp/-/regexpp-4.12.2.tgz -> npm-33d1e36615c6285c-regexpp-4.12.2.tgz
	https://registry.npmjs.org/@eslint/config-array/-/config-array-0.21.2.tgz ->
		npm-875d0fd67bffb7a1-config-array-0.21.2.tgz
	https://registry.npmjs.org/@eslint/config-helpers/-/config-helpers-0.4.2.tgz ->
		npm-5267e6b84d9b50af-config-helpers-0.4.2.tgz
	https://registry.npmjs.org/@eslint/core/-/core-0.17.0.tgz -> npm-c28bc9ac1df351d1-core-0.17.0.tgz
	https://registry.npmjs.org/@eslint/eslintrc/-/eslintrc-3.3.7.tgz -> npm-67af2b9be6e14427-eslintrc-3.3.7.tgz
	https://registry.npmjs.org/@eslint/js/-/js-9.39.5.tgz -> npm-1520b7fe8375af84-js-9.39.5.tgz
	https://registry.npmjs.org/@eslint/object-schema/-/object-schema-2.1.7.tgz ->
		npm-bcfd558f52d02b70-object-schema-2.1.7.tgz
	https://registry.npmjs.org/@eslint/plugin-kit/-/plugin-kit-0.4.1.tgz -> npm-8c960a6f3e29e7ca-plugin-kit-0.4.1.tgz
	https://registry.npmjs.org/@fontsource/fira-code/-/fira-code-5.3.0.tgz -> npm-0e608ddf1a3b988b-fira-code-5.3.0.tgz
	https://registry.npmjs.org/@fontsource/fira-sans/-/fira-sans-5.3.0.tgz -> npm-19b84c0477161a41-fira-sans-5.3.0.tgz
	https://registry.npmjs.org/@humanfs/core/-/core-0.19.2.tgz -> npm-3bac56654b8e31e6-core-0.19.2.tgz
	https://registry.npmjs.org/@humanfs/node/-/node-0.16.8.tgz -> npm-548e504f6abddf48-node-0.16.8.tgz
	https://registry.npmjs.org/@humanfs/types/-/types-0.15.0.tgz -> npm-a9916eec4f9d9b74-types-0.15.0.tgz
	https://registry.npmjs.org/@humanwhocodes/module-importer/-/module-importer-1.0.1.tgz ->
		npm-cb76f54cae5e901f-module-importer-1.0.1.tgz
	https://registry.npmjs.org/@humanwhocodes/retry/-/retry-0.4.3.tgz -> npm-000ec49ac4651c68-retry-0.4.3.tgz
	https://registry.npmjs.org/@oxc-project/types/-/types-0.148.0.tgz -> npm-35a056cecbe86a12-types-0.148.0.tgz
	https://registry.npmjs.org/@rolldown/binding-linux-x64-gnu/-/binding-linux-x64-gnu-1.2.7.tgz ->
		npm-19f50d439d870211-binding-linux-x64-gnu-1.2.7.tgz
	https://registry.npmjs.org/@rolldown/binding-linux-x64-musl/-/binding-linux-x64-musl-1.2.7.tgz ->
		npm-8acf0fec602772e5-binding-linux-x64-musl-1.2.7.tgz
	https://registry.npmjs.org/@rolldown/pluginutils/-/pluginutils-1.0.1.tgz -> npm-a11950e6d1dc0dfd-pluginutils-1.0.1.tgz
	https://registry.npmjs.org/@types/estree/-/estree-1.0.9.tgz -> npm-7e8339d3880aa72d-estree-1.0.9.tgz
	https://registry.npmjs.org/@types/json-schema/-/json-schema-7.0.15.tgz -> npm-e139267cb5b71a23-json-schema-7.0.15.tgz
	https://registry.npmjs.org/@vitejs/plugin-react/-/plugin-react-6.1.1.tgz -> npm-a4d780a60a752c01-plugin-react-6.1.1.tgz
	https://registry.npmjs.org/acorn-jsx/-/acorn-jsx-5.3.2.tgz -> npm-18225d14cfe5750a-acorn-jsx-5.3.2.tgz
	https://registry.npmjs.org/acorn/-/acorn-8.18.0.tgz -> npm-27993fd7bc5b03d4-acorn-8.18.0.tgz
	https://registry.npmjs.org/ajv/-/ajv-6.15.0.tgz -> npm-41d28777f840088f-ajv-6.15.0.tgz
	https://registry.npmjs.org/ansi-styles/-/ansi-styles-4.3.0.tgz -> npm-c470e069fb07ede1-ansi-styles-4.3.0.tgz
	https://registry.npmjs.org/argparse/-/argparse-2.0.1.tgz -> npm-ed4cfbf2dd38e880-argparse-2.0.1.tgz
	https://registry.npmjs.org/array-buffer-byte-length/-/array-buffer-byte-length-1.0.2.tgz ->
		npm-b04ef2520a9ca3f0-array-buffer-byte-length-1.0.2.tgz
	https://registry.npmjs.org/array-includes/-/array-includes-3.1.9.tgz -> npm-40b149e2a5e86788-array-includes-3.1.9.tgz
	https://registry.npmjs.org/array.prototype.findlast/-/array.prototype.findlast-1.2.5.tgz ->
		npm-be8b2b91abcb2bd5-array.prototype.findlast-1.2.5.tgz
	https://registry.npmjs.org/array.prototype.flat/-/array.prototype.flat-1.3.3.tgz ->
		npm-8ede876e1f9c4038-array.prototype.flat-1.3.3.tgz
	https://registry.npmjs.org/array.prototype.flatmap/-/array.prototype.flatmap-1.3.3.tgz ->
		npm-0cd54d98d65fc107-array.prototype.flatmap-1.3.3.tgz
	https://registry.npmjs.org/array.prototype.tosorted/-/array.prototype.tosorted-1.1.4.tgz ->
		npm-bd63874eb12b36fa-array.prototype.tosorted-1.1.4.tgz
	https://registry.npmjs.org/arraybuffer.prototype.slice/-/arraybuffer.prototype.slice-1.0.4.tgz ->
		npm-38ee8cb60211ba78-arraybuffer.prototype.slice-1.0.4.tgz
	https://registry.npmjs.org/async-function/-/async-function-1.0.0.tgz -> npm-66b23e70d4e22eb4-async-function-1.0.0.tgz
	https://registry.npmjs.org/available-typed-arrays/-/available-typed-arrays-1.0.7.tgz ->
		npm-3947810f4c001881-available-typed-arrays-1.0.7.tgz
	https://registry.npmjs.org/balanced-match/-/balanced-match-1.0.2.tgz -> npm-ec5877ed18a11e22-balanced-match-1.0.2.tgz
	https://registry.npmjs.org/brace-expansion/-/brace-expansion-1.1.18.tgz ->
		npm-e5ed2ebeb3cc5f31-brace-expansion-1.1.18.tgz
	https://registry.npmjs.org/call-bind-apply-helpers/-/call-bind-apply-helpers-1.0.2.tgz ->
		npm-8645fee083179987-call-bind-apply-helpers-1.0.2.tgz
	https://registry.npmjs.org/call-bind/-/call-bind-1.0.9.tgz -> npm-2b81b7f258eeff26-call-bind-1.0.9.tgz
	https://registry.npmjs.org/call-bound/-/call-bound-1.0.4.tgz -> npm-6b882a98d03a3d17-call-bound-1.0.4.tgz
	https://registry.npmjs.org/callsites/-/callsites-3.1.0.tgz -> npm-9e3ce4f72f4468d4-callsites-3.1.0.tgz
	https://registry.npmjs.org/chalk/-/chalk-4.1.2.tgz -> npm-a5d2ec6499281633-chalk-4.1.2.tgz
	https://registry.npmjs.org/color-convert/-/color-convert-2.0.1.tgz -> npm-eb020ce03a589c96-color-convert-2.0.1.tgz
	https://registry.npmjs.org/color-name/-/color-name-1.1.4.tgz -> npm-b37af03af608f651-color-name-1.1.4.tgz
	https://registry.npmjs.org/concat-map/-/concat-map-0.0.1.tgz -> npm-8b87ad5636a59d94-concat-map-0.0.1.tgz
	https://registry.npmjs.org/cross-spawn/-/cross-spawn-7.0.6.tgz -> npm-eaa5b7e7300c7bb1-cross-spawn-7.0.6.tgz
	https://registry.npmjs.org/data-view-buffer/-/data-view-buffer-1.0.2.tgz ->
		npm-c139a642e52a16e1-data-view-buffer-1.0.2.tgz
	https://registry.npmjs.org/data-view-byte-length/-/data-view-byte-length-1.0.2.tgz ->
		npm-fc689a485bf8a029-data-view-byte-length-1.0.2.tgz
	https://registry.npmjs.org/data-view-byte-offset/-/data-view-byte-offset-1.0.1.tgz ->
		npm-df8358eeeeb63893-data-view-byte-offset-1.0.1.tgz
	https://registry.npmjs.org/debug/-/debug-4.4.3.tgz -> npm-7b09c49ed17c7dc4-debug-4.4.3.tgz
	https://registry.npmjs.org/deep-is/-/deep-is-0.1.4.tgz -> npm-48691b85c9d16dff-deep-is-0.1.4.tgz
	https://registry.npmjs.org/define-data-property/-/define-data-property-1.1.4.tgz ->
		npm-dcbb02c2d76abbb6-define-data-property-1.1.4.tgz
	https://registry.npmjs.org/define-properties/-/define-properties-1.2.1.tgz ->
		npm-1ed4db8cbfaf0911-define-properties-1.2.1.tgz
	https://registry.npmjs.org/detect-libc/-/detect-libc-2.1.2.tgz -> npm-d7fefcec2f79eb28-detect-libc-2.1.2.tgz
	https://registry.npmjs.org/doctrine/-/doctrine-2.1.0.tgz -> npm-a0113109b07c09da-doctrine-2.1.0.tgz
	https://registry.npmjs.org/dunder-proto/-/dunder-proto-1.0.1.tgz -> npm-45b7183fb272447f-dunder-proto-1.0.1.tgz
	https://registry.npmjs.org/es-abstract-get/-/es-abstract-get-1.0.0.tgz ->
		npm-d9bbb8231971367e-es-abstract-get-1.0.0.tgz
	https://registry.npmjs.org/es-abstract/-/es-abstract-1.24.2.tgz -> npm-3d4e31d18adb1ef2-es-abstract-1.24.2.tgz
	https://registry.npmjs.org/es-define-property/-/es-define-property-1.0.1.tgz ->
		npm-0d628a1c7bfcf326-es-define-property-1.0.1.tgz
	https://registry.npmjs.org/es-errors/-/es-errors-1.3.0.tgz -> npm-bf0bdfb9bb777e9b-es-errors-1.3.0.tgz
	https://registry.npmjs.org/es-iterator-helpers/-/es-iterator-helpers-1.4.0.tgz ->
		npm-cf05d0f31dd22cbc-es-iterator-helpers-1.4.0.tgz
	https://registry.npmjs.org/es-object-atoms/-/es-object-atoms-1.1.2.tgz ->
		npm-9fad61a330853c71-es-object-atoms-1.1.2.tgz
	https://registry.npmjs.org/es-set-tostringtag/-/es-set-tostringtag-2.1.0.tgz ->
		npm-51838b8c6bffeaa8-es-set-tostringtag-2.1.0.tgz
	https://registry.npmjs.org/es-shim-unscopables/-/es-shim-unscopables-1.1.0.tgz ->
		npm-ca2da7001b137e4a-es-shim-unscopables-1.1.0.tgz
	https://registry.npmjs.org/es-to-primitive/-/es-to-primitive-1.3.4.tgz ->
		npm-8e0b43e6a7ce84b7-es-to-primitive-1.3.4.tgz
	https://registry.npmjs.org/esbuild/-/esbuild-0.28.2.tgz -> npm-46d93a2a2585e194-esbuild-0.28.2.tgz
	https://registry.npmjs.org/escape-string-regexp/-/escape-string-regexp-4.0.0.tgz ->
		npm-e2f5d2ef8e769aef-escape-string-regexp-4.0.0.tgz
	https://registry.npmjs.org/eslint-plugin-react-hooks/-/eslint-plugin-react-hooks-5.2.0.tgz ->
		npm-807423b736b119e9-eslint-plugin-react-hooks-5.2.0.tgz
	https://registry.npmjs.org/eslint-plugin-react/-/eslint-plugin-react-7.37.5.tgz ->
		npm-5a69b61dc6af80cc-eslint-plugin-react-7.37.5.tgz
	https://registry.npmjs.org/eslint-scope/-/eslint-scope-8.4.0.tgz -> npm-52a646d014305189-eslint-scope-8.4.0.tgz
	https://registry.npmjs.org/eslint-visitor-keys/-/eslint-visitor-keys-3.4.3.tgz ->
		npm-fa8b8ba7787d626b-eslint-visitor-keys-3.4.3.tgz
	https://registry.npmjs.org/eslint-visitor-keys/-/eslint-visitor-keys-4.2.1.tgz ->
		npm-22a135314758c7f4-eslint-visitor-keys-4.2.1.tgz
	https://registry.npmjs.org/eslint/-/eslint-9.39.5.tgz -> npm-102457e04ffebe1b-eslint-9.39.5.tgz
	https://registry.npmjs.org/espree/-/espree-10.4.0.tgz -> npm-44fe66a89e2b9f94-espree-10.4.0.tgz
	https://registry.npmjs.org/esquery/-/esquery-1.7.0.tgz -> npm-557b29302b489837-esquery-1.7.0.tgz
	https://registry.npmjs.org/esrecurse/-/esrecurse-4.3.0.tgz -> npm-885b72dfbc9ddc90-esrecurse-4.3.0.tgz
	https://registry.npmjs.org/estraverse/-/estraverse-5.3.0.tgz -> npm-4b2534dd23a6ad06-estraverse-5.3.0.tgz
	https://registry.npmjs.org/esutils/-/esutils-2.0.3.tgz -> npm-2f90723beaf14bbb-esutils-2.0.3.tgz
	https://registry.npmjs.org/fast-deep-equal/-/fast-deep-equal-3.1.3.tgz ->
		npm-dcfa53f63690b412-fast-deep-equal-3.1.3.tgz
	https://registry.npmjs.org/fast-json-stable-stringify/-/fast-json-stable-stringify-2.1.0.tgz ->
		npm-a4fb0aea126214d3-fast-json-stable-stringify-2.1.0.tgz
	https://registry.npmjs.org/fast-levenshtein/-/fast-levenshtein-2.0.6.tgz ->
		npm-53ee7a8a0dfa7afd-fast-levenshtein-2.0.6.tgz
	https://registry.npmjs.org/fdir/-/fdir-6.5.0.tgz -> npm-b2caafa9a386895c-fdir-6.5.0.tgz
	https://registry.npmjs.org/file-entry-cache/-/file-entry-cache-8.0.0.tgz ->
		npm-a496f3b0767ecca1-file-entry-cache-8.0.0.tgz
	https://registry.npmjs.org/find-up/-/find-up-5.0.0.tgz -> npm-89c46d8d2560302d-find-up-5.0.0.tgz
	https://registry.npmjs.org/flat-cache/-/flat-cache-4.0.1.tgz -> npm-76ca6aee25baad73-flat-cache-4.0.1.tgz
	https://registry.npmjs.org/flatted/-/flatted-3.4.4.tgz -> npm-08a5a3bcd5a7bb91-flatted-3.4.4.tgz
	https://registry.npmjs.org/for-each/-/for-each-0.3.5.tgz -> npm-03d7ec3e8752e315-for-each-0.3.5.tgz
	https://registry.npmjs.org/function-bind/-/function-bind-1.1.2.tgz -> npm-e8bad89ecbdd2063-function-bind-1.1.2.tgz
	https://registry.npmjs.org/function.prototype.name/-/function.prototype.name-1.2.0.tgz ->
		npm-26e541a39146983a-function.prototype.name-1.2.0.tgz
	https://registry.npmjs.org/functions-have-names/-/functions-have-names-1.2.3.tgz ->
		npm-6c7100c211bc437b-functions-have-names-1.2.3.tgz
	https://registry.npmjs.org/generator-function/-/generator-function-2.0.1.tgz ->
		npm-331d9fd87efb11af-generator-function-2.0.1.tgz
	https://registry.npmjs.org/get-intrinsic/-/get-intrinsic-1.3.0.tgz -> npm-971ebb74c5f68360-get-intrinsic-1.3.0.tgz
	https://registry.npmjs.org/get-proto/-/get-proto-1.0.1.tgz -> npm-13286db5ec49d99d-get-proto-1.0.1.tgz
	https://registry.npmjs.org/get-symbol-description/-/get-symbol-description-1.1.0.tgz ->
		npm-2a4fb3ace2642cfe-get-symbol-description-1.1.0.tgz
	https://registry.npmjs.org/glob-parent/-/glob-parent-6.0.2.tgz -> npm-4045ccd200bba9a7-glob-parent-6.0.2.tgz
	https://registry.npmjs.org/globals/-/globals-14.0.0.tgz -> npm-f0c3867f2138ff86-globals-14.0.0.tgz
	https://registry.npmjs.org/globals/-/globals-16.5.0.tgz -> npm-c8a695709518d5c5-globals-16.5.0.tgz
	https://registry.npmjs.org/globalthis/-/globalthis-1.0.4.tgz -> npm-f2bdfe6c228b6592-globalthis-1.0.4.tgz
	https://registry.npmjs.org/gopd/-/gopd-1.2.0.tgz -> npm-5dca37d76957dc23-gopd-1.2.0.tgz
	https://registry.npmjs.org/has-bigints/-/has-bigints-1.1.0.tgz -> npm-51757e3064e830af-has-bigints-1.1.0.tgz
	https://registry.npmjs.org/has-flag/-/has-flag-4.0.0.tgz -> npm-ead74f681a5c07c9-has-flag-4.0.0.tgz
	https://registry.npmjs.org/has-property-descriptors/-/has-property-descriptors-1.0.2.tgz ->
		npm-2fa0d4bd3b43f73b-has-property-descriptors-1.0.2.tgz
	https://registry.npmjs.org/has-proto/-/has-proto-1.2.0.tgz -> npm-dbd33e19d7e5835d-has-proto-1.2.0.tgz
	https://registry.npmjs.org/has-symbols/-/has-symbols-1.1.0.tgz -> npm-cffb53f16b20a8f0-has-symbols-1.1.0.tgz
	https://registry.npmjs.org/has-tostringtag/-/has-tostringtag-1.0.2.tgz ->
		npm-4580cc6668f74af2-has-tostringtag-1.0.2.tgz
	https://registry.npmjs.org/hasown/-/hasown-2.0.4.tgz -> npm-1f5bc6ae0d0df257-hasown-2.0.4.tgz
	https://registry.npmjs.org/ignore/-/ignore-5.3.2.tgz -> npm-e2f795c7b6c17bf7-ignore-5.3.2.tgz
	https://registry.npmjs.org/import-fresh/-/import-fresh-3.3.1.tgz -> npm-33af58fde77e93e9-import-fresh-3.3.1.tgz
	https://registry.npmjs.org/imurmurhash/-/imurmurhash-0.1.4.tgz -> npm-6c5170ee9a7342d1-imurmurhash-0.1.4.tgz
	https://registry.npmjs.org/internal-slot/-/internal-slot-1.1.0.tgz -> npm-3f28b0af10c25d54-internal-slot-1.1.0.tgz
	https://registry.npmjs.org/is-array-buffer/-/is-array-buffer-3.0.5.tgz ->
		npm-8d7f38d4cd92a15a-is-array-buffer-3.0.5.tgz
	https://registry.npmjs.org/is-async-function/-/is-async-function-2.1.1.tgz ->
		npm-7b899987537cdb50-is-async-function-2.1.1.tgz
	https://registry.npmjs.org/is-bigint/-/is-bigint-1.1.0.tgz -> npm-7941a5461295a0ce-is-bigint-1.1.0.tgz
	https://registry.npmjs.org/is-boolean-object/-/is-boolean-object-1.2.2.tgz ->
		npm-b11274c4ab3b02a8-is-boolean-object-1.2.2.tgz
	https://registry.npmjs.org/is-callable/-/is-callable-1.2.7.tgz -> npm-7cd4d0c373ab5f91-is-callable-1.2.7.tgz
	https://registry.npmjs.org/is-core-module/-/is-core-module-2.16.2.tgz -> npm-8a8bb4fcb198182a-is-core-module-2.16.2.tgz
	https://registry.npmjs.org/is-data-view/-/is-data-view-1.0.2.tgz -> npm-58c7bc9c5ab583a5-is-data-view-1.0.2.tgz
	https://registry.npmjs.org/is-date-object/-/is-date-object-1.1.0.tgz -> npm-b5d2dfa167d4e958-is-date-object-1.1.0.tgz
	https://registry.npmjs.org/is-document.all/-/is-document.all-1.0.0.tgz ->
		npm-7b1a32aa4d9b9852-is-document.all-1.0.0.tgz
	https://registry.npmjs.org/is-extglob/-/is-extglob-2.1.1.tgz -> npm-f3bb75392d5057a5-is-extglob-2.1.1.tgz
	https://registry.npmjs.org/is-finalizationregistry/-/is-finalizationregistry-1.1.1.tgz ->
		npm-9d0736a298780db2-is-finalizationregistry-1.1.1.tgz
	https://registry.npmjs.org/is-generator-function/-/is-generator-function-1.1.2.tgz ->
		npm-da9efeb900abbd5b-is-generator-function-1.1.2.tgz
	https://registry.npmjs.org/is-glob/-/is-glob-4.0.3.tgz -> npm-20086cdd9509b3b0-is-glob-4.0.3.tgz
	https://registry.npmjs.org/is-map/-/is-map-2.0.3.tgz -> npm-f03a63f61d771cde-is-map-2.0.3.tgz
	https://registry.npmjs.org/is-negative-zero/-/is-negative-zero-2.0.3.tgz ->
		npm-323b50ee9f8469b4-is-negative-zero-2.0.3.tgz
	https://registry.npmjs.org/is-number-object/-/is-number-object-1.1.1.tgz ->
		npm-3d2da65d451edb40-is-number-object-1.1.1.tgz
	https://registry.npmjs.org/is-regex/-/is-regex-1.2.1.tgz -> npm-38a010cd95990c69-is-regex-1.2.1.tgz
	https://registry.npmjs.org/is-set/-/is-set-2.0.3.tgz -> npm-9d3d70bcb03ef0d1-is-set-2.0.3.tgz
	https://registry.npmjs.org/is-shared-array-buffer/-/is-shared-array-buffer-1.0.4.tgz ->
		npm-cd9479e378076e3f-is-shared-array-buffer-1.0.4.tgz
	https://registry.npmjs.org/is-string/-/is-string-1.1.1.tgz -> npm-bf9cd39664db72ab-is-string-1.1.1.tgz
	https://registry.npmjs.org/is-symbol/-/is-symbol-1.1.1.tgz -> npm-d6ed705e51bb874c-is-symbol-1.1.1.tgz
	https://registry.npmjs.org/is-typed-array/-/is-typed-array-1.1.15.tgz -> npm-0943dd15c789917b-is-typed-array-1.1.15.tgz
	https://registry.npmjs.org/is-weakmap/-/is-weakmap-2.0.2.tgz -> npm-a87a387232d81bdd-is-weakmap-2.0.2.tgz
	https://registry.npmjs.org/is-weakref/-/is-weakref-1.1.1.tgz -> npm-a5e652e3eba14d7a-is-weakref-1.1.1.tgz
	https://registry.npmjs.org/is-weakset/-/is-weakset-2.0.4.tgz -> npm-feb44518b72bf433-is-weakset-2.0.4.tgz
	https://registry.npmjs.org/isarray/-/isarray-2.0.5.tgz -> npm-dc3c987d484e7276-isarray-2.0.5.tgz
	https://registry.npmjs.org/isexe/-/isexe-2.0.0.tgz -> npm-196757ee5bcda0ae-isexe-2.0.0.tgz
	https://registry.npmjs.org/iterator.prototype/-/iterator.prototype-1.1.5.tgz ->
		npm-39e14d477dbf93e4-iterator.prototype-1.1.5.tgz
	https://registry.npmjs.org/js-tokens/-/js-tokens-4.0.0.tgz -> npm-ec142c7bc942b358-js-tokens-4.0.0.tgz
	https://registry.npmjs.org/js-yaml/-/js-yaml-4.3.2.tgz -> npm-0ae1e3923f98aad5-js-yaml-4.3.2.tgz
	https://registry.npmjs.org/json-buffer/-/json-buffer-3.0.1.tgz -> npm-6f0cd18441903ac4-json-buffer-3.0.1.tgz
	https://registry.npmjs.org/json-schema-traverse/-/json-schema-traverse-0.4.1.tgz ->
		npm-19bc03d66df7d358-json-schema-traverse-0.4.1.tgz
	https://registry.npmjs.org/json-stable-stringify-without-jsonify/-/json-stable-stringify-without-jsonify-1.0.1.tgz ->
		npm-2097545824284386-json-stable-stringify-without-jsonify-1.0.1.tgz
	https://registry.npmjs.org/jsx-ast-utils/-/jsx-ast-utils-3.3.5.tgz -> npm-996a84edcb45dfb6-jsx-ast-utils-3.3.5.tgz
	https://registry.npmjs.org/keyv/-/keyv-4.5.4.tgz -> npm-d00ef92bc638db0d-keyv-4.5.4.tgz
	https://registry.npmjs.org/levn/-/levn-0.4.1.tgz -> npm-b4bc87e85e309130-levn-0.4.1.tgz
	https://registry.npmjs.org/lightningcss-linux-x64-gnu/-/lightningcss-linux-x64-gnu-1.33.0.tgz ->
		npm-077736c195809fb0-lightningcss-linux-x64-gnu-1.33.0.tgz
	https://registry.npmjs.org/lightningcss-linux-x64-musl/-/lightningcss-linux-x64-musl-1.33.0.tgz ->
		npm-e59a236538be85bf-lightningcss-linux-x64-musl-1.33.0.tgz
	https://registry.npmjs.org/lightningcss/-/lightningcss-1.33.0.tgz -> npm-fdd9a735e63bf4df-lightningcss-1.33.0.tgz
	https://registry.npmjs.org/locate-path/-/locate-path-6.0.0.tgz -> npm-efacea37cad6e2ad-locate-path-6.0.0.tgz
	https://registry.npmjs.org/lodash.merge/-/lodash.merge-4.6.2.tgz -> npm-b9537700dc0320a6-lodash.merge-4.6.2.tgz
	https://registry.npmjs.org/loose-envify/-/loose-envify-1.4.0.tgz -> npm-1ba9524360655f44-loose-envify-1.4.0.tgz
	https://registry.npmjs.org/lucide-react/-/lucide-react-0.468.0.tgz -> npm-741a0142b813940c-lucide-react-0.468.0.tgz
	https://registry.npmjs.org/math-intrinsics/-/math-intrinsics-1.1.0.tgz ->
		npm-65f1b46c600f005d-math-intrinsics-1.1.0.tgz
	https://registry.npmjs.org/minimatch/-/minimatch-3.1.5.tgz -> npm-3d86972e665a2ed3-minimatch-3.1.5.tgz
	https://registry.npmjs.org/ms/-/ms-2.1.3.tgz -> npm-7f1f904879825b70-ms-2.1.3.tgz
	https://registry.npmjs.org/nanoid/-/nanoid-3.3.18.tgz -> npm-bef9468d5763896a-nanoid-3.3.18.tgz
	https://registry.npmjs.org/natural-compare/-/natural-compare-1.4.0.tgz ->
		npm-8e9609d0af243837-natural-compare-1.4.0.tgz
	https://registry.npmjs.org/node-exports-info/-/node-exports-info-1.6.2.tgz ->
		npm-dbc738f8109ea0e1-node-exports-info-1.6.2.tgz
	https://registry.npmjs.org/object-assign/-/object-assign-4.1.1.tgz -> npm-896a1c7dae968dcf-object-assign-4.1.1.tgz
	https://registry.npmjs.org/object-inspect/-/object-inspect-1.13.4.tgz -> npm-636f8f44fb48c087-object-inspect-1.13.4.tgz
	https://registry.npmjs.org/object-keys/-/object-keys-1.1.1.tgz -> npm-a712176a765ddcf3-object-keys-1.1.1.tgz
	https://registry.npmjs.org/object.assign/-/object.assign-4.1.7.tgz -> npm-3040cf19dd887770-object.assign-4.1.7.tgz
	https://registry.npmjs.org/object.entries/-/object.entries-1.1.9.tgz -> npm-702468cf48916a59-object.entries-1.1.9.tgz
	https://registry.npmjs.org/object.fromentries/-/object.fromentries-2.0.8.tgz ->
		npm-d61aa45482034daf-object.fromentries-2.0.8.tgz
	https://registry.npmjs.org/object.values/-/object.values-1.2.1.tgz -> npm-232da0eef4dd5a6a-object.values-1.2.1.tgz
	https://registry.npmjs.org/optionator/-/optionator-0.9.4.tgz -> npm-0bb42eee8dcda366-optionator-0.9.4.tgz
	https://registry.npmjs.org/own-keys/-/own-keys-1.0.2.tgz -> npm-008996dc100a321f-own-keys-1.0.2.tgz
	https://registry.npmjs.org/p-limit/-/p-limit-3.1.0.tgz -> npm-2ca62ad7a9734023-p-limit-3.1.0.tgz
	https://registry.npmjs.org/p-locate/-/p-locate-5.0.0.tgz -> npm-951b4c6fb0613c68-p-locate-5.0.0.tgz
	https://registry.npmjs.org/parent-module/-/parent-module-1.0.1.tgz -> npm-b7a5be42b888fcb2-parent-module-1.0.1.tgz
	https://registry.npmjs.org/path-exists/-/path-exists-4.0.0.tgz -> npm-7e3134f4c1f04e9b-path-exists-4.0.0.tgz
	https://registry.npmjs.org/path-key/-/path-key-3.1.1.tgz -> npm-c8f90202160445d8-path-key-3.1.1.tgz
	https://registry.npmjs.org/path-parse/-/path-parse-1.0.7.tgz -> npm-9f13fd4b6f858c06-path-parse-1.0.7.tgz
	https://registry.npmjs.org/picocolors/-/picocolors-1.1.1.tgz -> npm-1aabc8b6282461d4-picocolors-1.1.1.tgz
	https://registry.npmjs.org/picomatch/-/picomatch-4.0.7.tgz -> npm-b8323ad9ab18da4a-picomatch-4.0.7.tgz
	https://registry.npmjs.org/possible-typed-array-names/-/possible-typed-array-names-1.1.0.tgz ->
		npm-e63e46e168ef8f94-possible-typed-array-names-1.1.0.tgz
	https://registry.npmjs.org/postcss/-/postcss-8.5.28.tgz -> npm-d32189906b1a050d-postcss-8.5.28.tgz
	https://registry.npmjs.org/prelude-ls/-/prelude-ls-1.2.1.tgz -> npm-83a895b491900942-prelude-ls-1.2.1.tgz
	https://registry.npmjs.org/prop-types/-/prop-types-15.8.1.tgz -> npm-84161b98d6fec47f-prop-types-15.8.1.tgz
	https://registry.npmjs.org/punycode/-/punycode-2.3.1.tgz -> npm-d73b161381dc69d5-punycode-2.3.1.tgz
	https://registry.npmjs.org/react-dom/-/react-dom-18.3.1.tgz -> npm-137a0a8f26141e67-react-dom-18.3.1.tgz
	https://registry.npmjs.org/react-is/-/react-is-16.13.1.tgz -> npm-720e9bfdc79663e7-react-is-16.13.1.tgz
	https://registry.npmjs.org/react/-/react-18.3.1.tgz -> npm-872a5684c1ab2016-react-18.3.1.tgz
	https://registry.npmjs.org/reflect.getprototypeof/-/reflect.getprototypeof-1.0.10.tgz ->
		npm-deabc134826449b4-reflect.getprototypeof-1.0.10.tgz
	https://registry.npmjs.org/regexp.prototype.flags/-/regexp.prototype.flags-1.5.4.tgz ->
		npm-9e0ec80f930cf33c-regexp.prototype.flags-1.5.4.tgz
	https://registry.npmjs.org/resolve-from/-/resolve-from-4.0.0.tgz -> npm-e5d210b50f31adcb-resolve-from-4.0.0.tgz
	https://registry.npmjs.org/resolve/-/resolve-2.0.0-next.7.tgz -> npm-f32abc37c83cd35b-resolve-2.0.0-next.7.tgz
	https://registry.npmjs.org/rolldown/-/rolldown-1.2.7.tgz -> npm-0316072c75fcff60-rolldown-1.2.7.tgz
	https://registry.npmjs.org/safe-array-concat/-/safe-array-concat-1.1.4.tgz ->
		npm-10badbb7cf8767c1-safe-array-concat-1.1.4.tgz
	https://registry.npmjs.org/safe-push-apply/-/safe-push-apply-1.0.0.tgz ->
		npm-6c69857c9c572d85-safe-push-apply-1.0.0.tgz
	https://registry.npmjs.org/safe-regex-test/-/safe-regex-test-1.1.0.tgz ->
		npm-439f35e68fbcc131-safe-regex-test-1.1.0.tgz
	https://registry.npmjs.org/scheduler/-/scheduler-0.23.2.tgz -> npm-1a52bb2adc3e596b-scheduler-0.23.2.tgz
	https://registry.npmjs.org/semver/-/semver-6.3.1.tgz -> npm-c11f472dbb89a47a-semver-6.3.1.tgz
	https://registry.npmjs.org/set-function-length/-/set-function-length-1.2.2.tgz ->
		npm-154e71457695092e-set-function-length-1.2.2.tgz
	https://registry.npmjs.org/set-function-name/-/set-function-name-2.0.2.tgz ->
		npm-a924e42e3d160d6c-set-function-name-2.0.2.tgz
	https://registry.npmjs.org/set-proto/-/set-proto-1.0.0.tgz -> npm-3e3847482dc09da6-set-proto-1.0.0.tgz
	https://registry.npmjs.org/shebang-command/-/shebang-command-2.0.0.tgz ->
		npm-b844643c113a74d5-shebang-command-2.0.0.tgz
	https://registry.npmjs.org/shebang-regex/-/shebang-regex-3.0.0.tgz -> npm-9bb398b24e03cdf7-shebang-regex-3.0.0.tgz
	https://registry.npmjs.org/side-channel-list/-/side-channel-list-1.0.1.tgz ->
		npm-2b565d463ed1ca9b-side-channel-list-1.0.1.tgz
	https://registry.npmjs.org/side-channel-map/-/side-channel-map-1.0.1.tgz ->
		npm-b255b72625085d5d-side-channel-map-1.0.1.tgz
	https://registry.npmjs.org/side-channel-weakmap/-/side-channel-weakmap-1.0.2.tgz ->
		npm-e043c2b4910c8d8d-side-channel-weakmap-1.0.2.tgz
	https://registry.npmjs.org/side-channel/-/side-channel-1.1.1.tgz -> npm-7cdadb7790552254-side-channel-1.1.1.tgz
	https://registry.npmjs.org/source-map-js/-/source-map-js-1.2.1.tgz -> npm-1f28c3431ddd7e5f-source-map-js-1.2.1.tgz
	https://registry.npmjs.org/stop-iteration-iterator/-/stop-iteration-iterator-1.1.0.tgz ->
		npm-7db69a73f22acf0f-stop-iteration-iterator-1.1.0.tgz
	https://registry.npmjs.org/string.prototype.matchall/-/string.prototype.matchall-4.1.0.tgz ->
		npm-c0686ec11eed797d-string.prototype.matchall-4.1.0.tgz
	https://registry.npmjs.org/string.prototype.repeat/-/string.prototype.repeat-1.0.0.tgz ->
		npm-e8d0c4ce96336ca9-string.prototype.repeat-1.0.0.tgz
	https://registry.npmjs.org/string.prototype.trim/-/string.prototype.trim-1.2.11.tgz ->
		npm-65d9080aa6b2fd60-string.prototype.trim-1.2.11.tgz
	https://registry.npmjs.org/string.prototype.trimend/-/string.prototype.trimend-1.0.10.tgz ->
		npm-1fc9dd02bcc5d7d1-string.prototype.trimend-1.0.10.tgz
	https://registry.npmjs.org/string.prototype.trimstart/-/string.prototype.trimstart-1.0.8.tgz ->
		npm-ea032fcef93c5f75-string.prototype.trimstart-1.0.8.tgz
	https://registry.npmjs.org/strip-json-comments/-/strip-json-comments-3.1.1.tgz ->
		npm-3431c3a26416f07d-strip-json-comments-3.1.1.tgz
	https://registry.npmjs.org/supports-color/-/supports-color-7.2.0.tgz -> npm-2922078a0690ba31-supports-color-7.2.0.tgz
	https://registry.npmjs.org/supports-preserve-symlinks-flag/-/supports-preserve-symlinks-flag-1.0.0.tgz ->
		npm-2f6952617f040704-supports-preserve-symlinks-flag-1.0.0.tgz
	https://registry.npmjs.org/tinyglobby/-/tinyglobby-0.2.17.tgz -> npm-58e91972fa4b4a3d-tinyglobby-0.2.17.tgz
	https://registry.npmjs.org/type-check/-/type-check-0.4.0.tgz -> npm-89881588aa2a7824-type-check-0.4.0.tgz
	https://registry.npmjs.org/typed-array-buffer/-/typed-array-buffer-1.0.3.tgz ->
		npm-e76388d10737ee5a-typed-array-buffer-1.0.3.tgz
	https://registry.npmjs.org/typed-array-byte-length/-/typed-array-byte-length-1.0.3.tgz ->
		npm-49b60b56de36c500-typed-array-byte-length-1.0.3.tgz
	https://registry.npmjs.org/typed-array-byte-offset/-/typed-array-byte-offset-1.0.4.tgz ->
		npm-6b8a76f896ee2973-typed-array-byte-offset-1.0.4.tgz
	https://registry.npmjs.org/typed-array-length/-/typed-array-length-1.0.8.tgz ->
		npm-8c2dc136cfbb6534-typed-array-length-1.0.8.tgz
	https://registry.npmjs.org/unbox-primitive/-/unbox-primitive-1.1.0.tgz ->
		npm-3064cdf6cd65e8e1-unbox-primitive-1.1.0.tgz
	https://registry.npmjs.org/uri-js/-/uri-js-4.4.1.tgz -> npm-30f2d942cf7edd9a-uri-js-4.4.1.tgz
	https://registry.npmjs.org/vite/-/vite-8.2.2.tgz -> npm-58c90a6c0c66b8e0-vite-8.2.2.tgz
	https://registry.npmjs.org/which-boxed-primitive/-/which-boxed-primitive-1.1.1.tgz ->
		npm-8303e7905cdb50de-which-boxed-primitive-1.1.1.tgz
	https://registry.npmjs.org/which-builtin-type/-/which-builtin-type-1.2.1.tgz ->
		npm-8fb567ff6e1b5ca4-which-builtin-type-1.2.1.tgz
	https://registry.npmjs.org/which-collection/-/which-collection-1.0.2.tgz ->
		npm-6fa276b5f4a3e3cf-which-collection-1.0.2.tgz
	https://registry.npmjs.org/which-typed-array/-/which-typed-array-1.1.22.tgz ->
		npm-9766eded13ec7334-which-typed-array-1.1.22.tgz
	https://registry.npmjs.org/which/-/which-2.0.2.tgz -> npm-141eed282ebc792d-which-2.0.2.tgz
	https://registry.npmjs.org/word-wrap/-/word-wrap-1.2.5.tgz -> npm-e41974d662ab2846-word-wrap-1.2.5.tgz
	https://registry.npmjs.org/yocto-queue/-/yocto-queue-0.1.0.tgz -> npm-46d09f78e9797b7c-yocto-queue-0.1.0.tgz
"
# END GENERATED NPM DISTFILES
S="${WORKDIR}/twig-twig-v${PV}"

# Twig has no redistribution license. Electron, React, Lucide and the bundled
# Fira fonts keep their upstream notices in the installed application.
LICENSE="all-rights-reserved BSD ISC MIT OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip !test? ( test )"

BDEPEND="
	app-arch/unzip
	>=net-libs/nodejs-22.12.0[npm]
	test? (
		dev-vcs/git
		net-misc/openssh
	)
"
RDEPEND="
	!dev-vcs/twig-bin
	|| (
		llvm-runtimes/libgcc
		sys-devel/gcc:*
	)
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	app-misc/ca-certificates
	app-shells/bash
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-vcs/git
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[gbm(+)]
	net-misc/openssh
	net-print/cups
	sys-apps/coreutils
	sys-apps/dbus
	>=sys-libs/glibc-2.25
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/libnotify
	x11-libs/pango
	x11-misc/xdg-utils
"

# Only the Electron runtime is prebuilt; Twig's renderer and preload are built
# below from the tagged sources with the exact package-lock.json dependencies.
QA_PREBUILT="opt/twig/*"
PATCHES=( "${FILESDIR}/${P}-standalone-tests.patch" )

src_unpack() {
	unpack "${P}.tar.gz"
	mkdir "${WORKDIR}/electron" || die
	cd "${WORKDIR}/electron" || die
	unpack "electron-v${ELECTRON_PV}-linux-x64.zip"
}

src_prepare() {
	default

	# The public release pins an obsolete Node major, but uses standard APIs
	# supported by current Node. Keep the package and lockfile in agreement.
	sed -i 's/"node": ">=20.19.0 <21"/"node": ">=22.12.0"/' \
		package.json package-lock.json || die

	# Packaging is handled here. Drop the unused release builders and GUI smoke
	# driver, including electron-builder's Git-only node-gyp dependency. npm
	# prunes the existing lock graph offline without updating retained versions.
	npm --offline --cache "${T}/npm-cache" --userconfig /dev/null pkg delete \
		devDependencies.electron devDependencies.electron-builder \
		devDependencies.playwright || die
	npm --offline --ignore-scripts --no-audit --no-fund \
		--cache "${T}/npm-cache" --userconfig /dev/null \
		install --package-lock-only || die
}

src_configure() {
	# Portage fetches and verifies all archives before its network sandbox is
	# entered. npm then reads local tarballs and verifies lockfile integrity.
	node "${FILESDIR}/npm-offline.mjs" prepare "${S}" "${DISTDIR}" || die
	npm --offline --ignore-scripts --no-audit --no-fund \
		--include=dev --include=optional \
		--cache "${T}/npm-cache" --userconfig /dev/null ci || die
}

src_compile() {
	npm --offline --cache "${T}/npm-cache" --userconfig /dev/null run build || die

	# Reuse upstream's fontconfig workaround with the same runtime version.
	node --input-type=module -e "
		import { writeFileSync } from 'node:fs';
		import { launcherScript } from './scripts/after-pack.mjs';
		writeFileSync('twig', launcherScript('twig'));
	" || die
}

src_test() {
	# Tests create their own disposable repositories and identities. Host Git
	# signing, hooks and aliases must not affect the fixture repositories.
	GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 \
		npm --offline --cache "${T}/npm-cache" --userconfig /dev/null test || die
}

src_install() {
	local appdir=/opt/twig
	dodir "${appdir}"
	cp -a "${WORKDIR}/electron/." "${ED}${appdir}/" || die
	mv "${ED}${appdir}/electron" "${ED}${appdir}/twig.bin" || die
	# The application in resources/app replaces Electron's demonstration app.
	rm "${ED}${appdir}/resources/default_app.asar" || die
	# Use Chromium's user namespace sandbox, without a setuid helper.
	rm "${ED}${appdir}/chrome-sandbox" || die

	exeinto "${appdir}"
	doexe twig
	insinto "${appdir}/etc/fonts"
	doins build/fontconfig/fonts.conf
	insinto "${appdir}/resources/app"
	doins package.json
	doins -r main dist
	insinto "${appdir}/resources/app/renderer/src/features/automations"
	doins renderer/src/features/automations/*.js
	insinto "${appdir}/resources/app/build"
	doins build/icon.png

	# Vite embeds these assets in the renderer; keep their license notices.
	dodoc README.md CHANGELOG.md
	newdoc node_modules/react/LICENSE react-LICENSE
	newdoc node_modules/react-dom/LICENSE react-dom-LICENSE
	newdoc node_modules/lucide-react/LICENSE lucide-react-LICENSE
	newdoc node_modules/@fontsource/fira-code/LICENSE fira-code-LICENSE
	newdoc node_modules/@fontsource/fira-sans/LICENSE fira-sans-LICENSE
	newdoc "${FILESDIR}/README.gentoo" README.gentoo

	dosym -r "${appdir}/twig" /usr/bin/twig
	newicon -s 1024 build/icon.png twig.png
	make_desktop_entry twig Twig twig 'Development;RevisionControl' \
		'StartupWMClass=twig'
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "Twig was built from source using the upstream Electron ${ELECTRON_PV} runtime."
	elog "Unprivileged user namespaces must be enabled for Chromium's sandbox."
}
