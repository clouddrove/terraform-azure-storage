# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2024-10-15
### :bug: Bug Fixes
- [`1001fd9`](https://github.com/clouddrove/terraform-azure-storage/commit/1001fd9f47d34d132c46aa1a5ace2734290f6c32) - renamed _examples to examples and referenced it *(PR [#64](https://github.com/clouddrove/terraform-azure-storage/pull/64) by [@vjdbj](https://github.com/vjdbj))*
- [`b30a448`](https://github.com/clouddrove/terraform-azure-storage/commit/b30a44844c12db433781b4490ee1e7b5efe0a857) - Update https_traffic_only_enabled to enable_https_traffic_only *(PR [#74](https://github.com/clouddrove/terraform-azure-storage/pull/74) by [@ravimalvia10](https://github.com/ravimalvia10))*

### :construction_worker: Build System
- [`5fc506e`](https://github.com/clouddrove/terraform-azure-storage/commit/5fc506e7ac1f659649df9e5fa63d349427e2a860) - **deps**: bump clouddrove/github-shared-workflows from 1.2.4 to 1.2.8 *(commit by [@dependabot[bot]](https://github.com/apps/dependabot))*

### :memo: Documentation Changes
- [`6b4d3dc`](https://github.com/clouddrove/terraform-azure-storage/commit/6b4d3dc284dd8773e9c893ba39445b01bfe6a5c2) - update CHANGELOG.md for 1.1.0 *(commit by [@clouddrove-ci](https://github.com/clouddrove-ci))*


## [1.1.0] - 2024-07-26
### :sparkles: New Features
- [`fae3fb8`](https://github.com/clouddrove/terraform-azure-storage/commit/fae3fb8b344450ac5845c7d44901fd597487176b) - added required arguments *(commit by [@cloudlovely](https://github.com/cloudlovely))*
- [`a313fc2`](https://github.com/clouddrove/terraform-azure-storage/commit/a313fc23694de965a3af9a875ae20e8bf2cc1b48) - extra tags *(PR [#47](https://github.com/clouddrove/terraform-azure-storage/pull/47) by [@Rupalgw](https://github.com/Rupalgw))*

### :bug: Bug Fixes
- [`269df13`](https://github.com/clouddrove/terraform-azure-storage/commit/269df1309b19cc6c1f75542e840ff77458a0f6b1) - added key vault expiry date *(commit by [@cloudlovely](https://github.com/cloudlovely))*
- [`cd729f3`](https://github.com/clouddrove/terraform-azure-storage/commit/cd729f3946258b60c3882393ffd807c20c954cca) - fixed commented lines *(commit by [@cloudlovely](https://github.com/cloudlovely))*
- [`aeeacfd`](https://github.com/clouddrove/terraform-azure-storage/commit/aeeacfd00a13d3e73960499ca7717183d67593c5) - fixed code format *(commit by [@cloudlovely](https://github.com/cloudlovely))*
- [`ce81c13`](https://github.com/clouddrove/terraform-azure-storage/commit/ce81c1343dbbf76097edd926af07ab08569f4d04) - added expiration date *(commit by [@cloudlovely](https://github.com/cloudlovely))*
- [`adb2e2f`](https://github.com/clouddrove/terraform-azure-storage/commit/adb2e2f2d3d5041947a12211b0253f2cfbe6e70c) - fixed code format *(commit by [@cloudlovely](https://github.com/cloudlovely))*
- [`0388bd4`](https://github.com/clouddrove/terraform-azure-storage/commit/0388bd46a70bb0595be8d81cc2c1110c3c30a998) - created variable for key expiration *(commit by [@cloudlovely](https://github.com/cloudlovely))*
- [`d1bdf64`](https://github.com/clouddrove/terraform-azure-storage/commit/d1bdf6434f3ac7356e50a55ded790e340d8e6b36) - removed one storage resource and added required arguments in the module *(commit by [@cloudlovely](https://github.com/cloudlovely))*
- [`23bbea4`](https://github.com/clouddrove/terraform-azure-storage/commit/23bbea420efc42ba8e63194586b0951bc3a08dbf) - fixed key-vault authentication issue in cmk encryption *(commit by [@cloudlovely](https://github.com/cloudlovely))*
- [`a2dce2c`](https://github.com/clouddrove/terraform-azure-storage/commit/a2dce2c3b9026e8c81ba893f2681c299afd826b1) - updated all github workflows *(commit by [@cloudlovely](https://github.com/cloudlovely))*
- [`3c52c42`](https://github.com/clouddrove/terraform-azure-storage/commit/3c52c42069f3edae030966d5a32a61f0ed23c6e4) - tf destroy issue fixed *(commit by [@cloudlovely](https://github.com/cloudlovely))*
- [`9a183e1`](https://github.com/clouddrove/terraform-azure-storage/commit/9a183e1ae2c3997d4028464064445a1a0633c3a7) - fixed tfsec *(commit by [@cloudlovely](https://github.com/cloudlovely))*
- [`ea3a297`](https://github.com/clouddrove/terraform-azure-storage/commit/ea3a2970b5618a2cc132dbe670910171fe902550) - resource control conditions *(commit by [@d4kverma](https://github.com/d4kverma))*
- [`c745602`](https://github.com/clouddrove/terraform-azure-storage/commit/c7456023c06429d4323d1f8d9416848cad8be859) - encryption key expire fixed *(commit by [@d4kverma](https://github.com/d4kverma))*
- [`fef1226`](https://github.com/clouddrove/terraform-azure-storage/commit/fef1226f312d4747f772ba7883d06434e1d2fa77) - fixed the multiple provider issue *(commit by [@ravimalvia10](https://github.com/ravimalvia10))*

### :construction_worker: Build System
- [`2e3b57f`](https://github.com/clouddrove/terraform-azure-storage/commit/2e3b57f604edfbf4b677a1bdea9167610b4da789) - **deps**: bump pre-commit/action from 3.0.0 to 3.0.1 *(commit by [@dependabot[bot]](https://github.com/apps/dependabot))*
- [`8082dbd`](https://github.com/clouddrove/terraform-azure-storage/commit/8082dbd1950160572bec3aae7db0c180e7122b62) - **deps**: bump clouddrove/github-shared-workflows from 1.2.1 to 1.2.2 *(commit by [@dependabot[bot]](https://github.com/apps/dependabot))*
- [`5a3c1d2`](https://github.com/clouddrove/terraform-azure-storage/commit/5a3c1d2dfa66c7bf5d997f19985fa4b663d44cb1) - **deps**: bump clouddrove/github-shared-workflows from 1.2.2 to 1.2.4 *(commit by [@dependabot[bot]](https://github.com/apps/dependabot))*

### :memo: Documentation Changes
- [`11c2be3`](https://github.com/clouddrove/terraform-azure-storage/commit/11c2be3b397a1ab4ab5a33cbf3f49002b04f592a) - update CHANGELOG.md for 1.0.9 *(commit by [@clouddrove-ci](https://github.com/clouddrove-ci))*


## [1.0.9] - 2023-09-26
### :bug: Bug Fixes
- [`ce51387`](https://github.com/clouddrove/terraform-azure-storage/commit/ce51387b147571079f5a97657f0997037a81b347) - Updated access policy condition, network rules variable and added comments *(commit by [@13archit](https://github.com/13archit))*
- [`6883a83`](https://github.com/clouddrove/terraform-azure-storage/commit/6883a83b295a542f6534fc6baf6136107844bc8a) - Updated example folder hierarchy and dependabot.yml *(commit by [@13archit](https://github.com/13archit))*

### :construction_worker: Build System
- [`1e32e66`](https://github.com/clouddrove/terraform-azure-storage/commit/1e32e66616e035c5ee6247ff683849de5e07249f) - added tfsec workflow *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*

### :memo: Documentation Changes
- [`d081d08`](https://github.com/clouddrove/terraform-azure-storage/commit/d081d08a902edc43dd8582bb698e6736145774c0) - update CHANGELOG.md for 1.0.8 *(commit by [@13archit](https://github.com/13archit))*


## [1.0.8] - 2023-05-05
### :sparkles: New Features
- [`f965b40`](https://github.com/clouddrove/terraform-azure-storage/commit/f965b404036b400bdfaa9fec3227bf022086d6c3) - auto changelog action added *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*
- [`97a8ab9`](https://github.com/clouddrove/terraform-azure-storage/commit/97a8ab9e74c9141955aa03c803ed4065f403c082) - added dependabot.yml file *(commit by [@themaheshyadav](https://github.com/themaheshyadav))*


## [1.0.7] - 2022-04-07
### :bug: Bug Fixes
- [`255fa86`](https://github.com/clouddrove/terraform-azure-storage/commit/255fa8601d76d549b104c9faa83e8b959a500add) - Fix - storage account private endpoint is possible if it's in the same vnet

## [1.0.6] - 2022-03-27
### :bug: Bug Fixes
- [`f1d591d`](https://github.com/clouddrove/terraform-azure-storage/commit/f1d591d76b4f143640e38eb25210296066135da7) - Added versioning enabled argument

## [1.0.5] - 2022-03-13
### :sparkles: New Features
- [`cd20b31`](https://github.com/clouddrove/terraform-azure-storage/commit/cd20b317695af567b6d9012d80d77d307bbf88a2) - Added diagnostic settings for the resource

## [1.0.4] - 2022-03-07
### :sparkles: New Features
- [`fb4041c`](https://github.com/clouddrove/terraform-azure-storage/commit/fb4041c59f05f278bf7ae4d7393604ec9d335b06) - Added private endpoint
### :bug: Bug Fixes
- [`d536568`](https://github.com/clouddrove/terraform-azure-storage/commit/d536568338ed0013a999243a750ed4764c2eb37e) - existing dns condition added

## [1.0.3] - 2022-02-21
### :sparkles: New Features
- [`a16ed67`](https://github.com/clouddrove/terraform-azure-storage/commit/a16ed67f18fcfb88bd62195d1c9c4b39ca0cac4b) - Added another example with cmk encryption

## [1.0.2] - 2022-01-10
### :sparkles: New Features
- [`ac9f252`](https://github.com/clouddrove/terraform-azure-storage/commit/ac9f252e4e17bce63c1fd78c5f24a3ed3e6a02cb) - Added extra services in storage account

## [1.0.1] - 2022-12-12
### :sparkles: New Features
- [`15b5996`](https://github.com/clouddrove/terraform-azure-storage/commit/15b5996c4884bf144be66c405e0c016de3f8b26e) - Update module

## [1.0.0] - 2022-12-08
### :sparkles: New Features
- [`15b5996`](https://github.com/clouddrove/terraform-azure-storage/commit/15b5996c4884bf144be66c405e0c016de3f8b26e) - Added Terraform Azure Storage Module.



[1.0.0]: https://github.com/clouddrove/terraform-azure-storage/compare/1.0.0...master
[1.0.1]: https://github.com/clouddrove/terraform-azure-storage/compare/1.0.0...1.0.1
[1.0.2]: https://github.com/clouddrove/terraform-azure-storage/compare/1.0.1...1.0.2
[1.0.3]: https://github.com/clouddrove/terraform-azure-storage/compare/1.0.2...1.0.3
[1.0.4]: https://github.com/clouddrove/terraform-azure-storage/compare/1.0.3...1.0.4
[1.0.5]: https://github.com/clouddrove/terraform-azure-storage/compare/1.0.4...1.0.5
[1.0.6]: https://github.com/clouddrove/terraform-azure-storage/compare/1.0.5...1.0.6
[1.0.7]: https://github.com/clouddrove/terraform-azure-storage/compare/1.0.5...1.0.6

[1.0.8]: https://github.com/clouddrove/terraform-azure-storage/compare/1.0.7...1.0.8
[1.0.9]: https://github.com/clouddrove/terraform-azure-storage/compare/1.0.8...1.0.9
[1.1.0]: https://github.com/clouddrove/terraform-azure-storage/compare/1.0.9...1.1.0
[1.1.1]: https://github.com/clouddrove/terraform-azure-storage/compare/1.1.0...1.1.1
