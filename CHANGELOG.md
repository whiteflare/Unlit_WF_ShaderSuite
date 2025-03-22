# Change Log

## 2025/03/23 (2.8.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20250323

### Changed
- GUI
  - マテリアル複数選択時にコピーメニュー非活性化していたのを非活性化しないようにしました。複数選択時は先頭1件のマテリアルをコピーします。
  - WFEditorSetting に「現在有効な設定ファイルを選択」ボタンを追加しました。

----

## 2025/01/28 (2.7.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20250128

### Added
- Shader
  - SDFテクスチャを使用して影を付ける機能を追加しました。

### Changed
- Shader
  - ToonShade のフェードアウト距離(Min)初期値を `1.0` から `2.0` に調整しました。
- GUI
  - GemのデフォルトをTransparentからOpaqueに変更しました。

----

## 2024/12/17 (2.6.1)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20241217

### Fixed
- Shader
  - エミッションを利用しているシェーダをライトベイクするとエラーが発生していた問題を修正しました。

----

## 2024/12/15 (2.6.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20241215

### Added
- Tool
  - AAO(AvatarOptimizer)と連携するコードを追加しました。UnlitWFを利用したマテリアルでもAAOの「テクスチャを最適化する」を利用できます。
- Other
  - テクスチャ類に褐色用の加算マットキャップ、およびラバー用の加算マットキャップを追加しました。

### Changed
- GUI
  - テクスチャをベイクする際、今まではメインテクスチャと同じ画像サイズのテクスチャを出力していましたが、マスクテクスチャを含めて設定されている画像の最大サイズで出力するよう変更しました。
  - matcap を設定した際、今まではファイル名が "lcap_" で始まる場合に合成モードを「加算」に変更していましたが、"mcap_" で始まらない場合に加算に変更するよう変更しました。

### Fixed
- Shader
  - Emissive AudioLink にて、ディレイが None の時にも「反転」が有効になっていた問題を修正しました。
- GUI
  - WFメニューを追加する際、コンソールにエラーが表示される場合があった問題を修正しました。
  - Unity2019 + VPM + VRCSDK3Avatar 環境でスクリプトエラーが発生する問題を修正しました。

----

## 2024/11/23 (2.5.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20241123

### Added
- Shader
  - 逆光ライト機能を追加しました。従来のリムライト機能よりさらに明るい光を加算合成します。
- GUI
  - VRCSDK3 Avatars 向け、マテリアルの明るさ等を調整するメニューを追加する機能を追加しました。
    - NDMFおよびModularAvatarと連携してExpressionメニューを追加します。それらが存在しないプロジェクトではメニュー追加機能のみ無効となります。
    - UnlitWF のVPMパッケージ版に機能が含まれています。unitypackage版にはこの機能は含まれていません。

### Changed
- Shader
  - エミッションでメインカラーを混合するToggleを追加しました。
- Tool
  - 「UnlitWFのマテリアルに変換する」にてエミッションの変換処理を改良しました。メインテクスチャが設定されているのにエミッションテクスチャが未設定のときにはエミッションをオフにするように変更しました。

----

## 2024/10/14 (2.4.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20241014

### Added
- GUI
  - メインテクスチャに色調整などをベイクするボタンを、インスペクタ最下部に追加しました。

### Changed
- Shader
  - Metallic の GSAA を、ToggleからRangeに変更しました。GSAAの適用具合を調整することができるようになりました。
  - リムライトでメインカラーを混合するToggleを追加しました。

----

## 2024-09-07 (2.3.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20240907

### Important Notice
- Shader
  - 配布ライセンスを MIT LICENSE から zlib/libpng License に変更しました。
    - 変更の意図: MIT LICENSE を厳密に適用すると、UnlitWFを使用したアバターやワールドにも著作権表示が必要となってしまう問題がありました。アバターやワールドにまで著作権表示を求めたくないため、より実態に即したライセンスである zlib/libpng License に変更します。
    - このライセンスの変更では、次の点は従来より変更ありません。
      - 無保証・無責任
      - 自由な利用の許可
      - 自由な改変と再頒布の許可
      - 虚偽の著作権表示の禁止
    - 過去バージョンのソースコードは MIT LICENSE が適用されています。より制限の緩い zlib/libpng License を用いた最新バージョンのソースコードをぜひお使いください。

### Changed
- Shader
  - 距離フェードとAOの適用順を入れ替えました。以前は距離フェードの効果にAOの効果を上乗せしてしまっていましたが、入れ替えによりAOに関わらず距離フェードの効果が掛かるようになりました。
- Tool
  - 特定のテクスチャがオフになっている場合、クリンナップ処理でそのテクスチャを外すようにしました。
    - 例えば、アルファマスクテクスチャが設定されているのにアルファ値をメインテクスチャから取得している場合、無駄な設定となっているアルファマスクを外してNoneにします。

----

## 2024-07-27 (2.2.1)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20240727

### Fixed
- Tool
  - Android環境にてシーンにMaterial Variantが含まれている場合に再生およびビルドのプログレスバーが完了しない問題を修正しました。
    - Project右クリックから「UnlitWFのマテリアルに変換する」または「モバイル向けシェーダに変換する」のとき、Material Variantを対象としたときはフラット化される仕様となりました。
  - 「UnlitWFのマテリアルに変換する」した結果、影2が影1と同じ色になってしまっていた問題を修正しました。

----

## 2024-07-21 (2.2.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20240721

### Added
- Shader
  - MainTexture 2nd 機能を追加しました。
  - EmissiveScroll に波形グラデーションテクスチャを追加しました。
  - EmissiveAudioLink にディレイを追加しました。

### Changed
- GUI
  - Hierarchy右クリックの「UnlitWF Shader/マテリアルのクリンナップ」を復活させました。
  - グラデーションマップを参照する時の縦座標を今までは 0.0 で参照していたものを 0.5 に変更しました。

### Fixed
- GUI
  - 機能を有効化したときにデフォルトテクスチャが割り当てられない問題を修正しました。

----

## 2024-06-12 (2.1.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20240612

### Changed
- Shader
  - Customの中に入れていたアウトライン付きPowerCapを `UnToon_PowerCap_Outline` として整理しました。
  - FakeFur のマスクを `長さマスク` と `アルファマスク` に分割しました。
- GUI
  - Custom Shader Variants の表示とシェーダ切り替えメニューを新しくしました。
  - ヘルプページを開くボタンを追加しました。
  - matcapを入れ替えるメニューを追加しました。

### Fixed
- GUI
  - Transparent系列のUnToonからUnityビルトインのUnlitに切り替えた後に描画が行われない問題を修正しました。
  - プロパティをリセットしたときにデフォルトテクスチャが割り当てられない問題を修正しました。

----

## 2024-05-25 (2.0.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20240525

### Removed
- Shader
  - Deprecatedとなっていた以下の機能を削除しました。
    - 3chカラーマスク
    - Metallic の「Metallicマップの種類」
    - リムライトの混合タイプ「乗算」
- GUI
  - GameObjectメニューの「UnlitWFマテリアルをクリンナップ」を削除しました。(GameObjectメニュー配下の整理のため)

### Notice
- Shader
  - Unitty2018向けシェーダ(シェーダキーワードを使わないもの)についてサポートを終了しました。最終版については以下のURLから取得可能です。
    - https://github.com/whiteflare/Unlit_WF_ShaderSuite/tree/head_unity2018

----

## 2024-04-07 (1.12.1)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20240407

### Fixed
- Shader
  - 特定の状況でラメが細かく点滅してしまう問題を修正しました。

----

## 2024-03-16 (1.12.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20240316

### Added
- Shader
  - アルファ強度をmin/max指定できるようにしました。従来までの最大値の調整に加えて、最小値の側も調整できるようにしています。

### Removed
- Shader
  - アルファ強度をmin/max指定できるようになったことに伴い、アルファマスクの 減算 モードを削除しました。

----

## 2024-03-10 (1.11.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20240310

### Added
- Shader
  - リムシャドウ 機能を追加しました。
  - アルファマスクに 減算 モードを追加しました。(1 - a * power) をアルファ値として出力します。
  - FrostedGlass に ブラーモード と ブラーランダム化 を追加しました。
  - FrostedGlass, Refracted, Water_Refracted に CameraDepthTexture を使う設定を追加しました。
    - なお VRCSDK3 Avatar プロジェクトでは強制的に無効化されます。WFEditorSettings.asset を参照してください。

### Deprecated
- Shader
  - リムシャドウの追加に伴い、従来のリムライト乗算モードはレガシーの警告を出すようにしました。

### Fixed
- Shader
  - ShadowCaster がアウトラインまでを覆うようになりました。DoFフィルタなどでも正しく動くようになります。
- Tool
  - 不要な影テクスチャ(2影までしか使っていないときの3影テクスチャなど)をクリンナップするようにしました。

----

## 2024-02-12 (1.10.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20240212

### Changed
- Shader
  - リムライト幅に関するパラメータを作り直しました。リムライトを更に調整しやすくなったはずです。
  - Refracted の屈折率を 1.0 以下に下げられるようにしました。これにより近視用レンズを作れるようになりました。
- GUI
  - 「逆光補正しない」をワールドではON固定にする設定を追加しました。変更は WFEditorSettings.asset から行えます。アバター向けプロジェクトでは従来通りマテリアルごとの設定です。

### Fixed
- Shader
  - FakeFur で距離フェードを使うとマテリアルエラーになっていたのを修正
  - Particle の Addition と Multiply で出力される alpha が変だったのを修正
  - Refracted で alpha = 0 のときに屈折効果ごと消えてしまっていたのを修正、FrostedGlass も同様に修正

----

## 2024-01-28 (1.9.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20240128

### Added
- Shader
  - WF_Particle 系シェーダを追加しました。パーティクル専用のシェーダになります。
  - リムライトに「乗算」モードを追加しました。リムシャドウを実現することができるようになりました。

### Changed
- Shader
  - 半透明系のEmissionに「透明度を反映」を追加しました。ベースの透明度をEmissionで上書きし、さらにEmissiveScrollやAudioLinkで透明度を上書きすることができるようになりました。
  - VRCFallbackの指定をマテリアルから行うことができるようになりました。

----

## 2024-01-01 (1.8.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20240101

### Fixed
- Shader
  - UnlitWFの内部構造を全般的に変更しました。描画結果に影響はないはずですが万一変化があった場合はお知らせください。
- Tool
  - Unity2020からのReordarableList標準搭載に伴い、一部のGUIが正しく動かない問題を修正しました。

----

## 2023-12-10 (1.7.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20231210

### Added
- Shader
  - グラデーションマップ機能を追加しました。
  - 色変更にガンマ調整とマスクテクスチャの機能を追加しました。

### Fixed
- Tool
  - 「マテリアルプロパティのコピー」ツールにて距離フェードがリストアップされなかった問題を修正しました。

----

## 2023-11-06 (1.6.1)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20231106

### Changed
- Shader
  - DirectXのノーマルマップを使用 のときの計算式を変更しました。また BumpScale に -1 を使えるようにしました。

----

## 2023-11-05 (1.6.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20231105

### Changed
- Shader
  - 半透明 alpha = 0 かつ ZWrite = ON のとき、従来では Z を書いていましたが、今回から Z を書かないようにしました。
    - それと合わせて、PlayerOnlyミラーで見たとき alpha = 0 の部分が見えてしまっていた問題を修正しました。
  - NormalMap のオプションに DirectXのノーマルマップを使用 を追加しました。

----

## 2023-10-11 (1.5.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20231011

### Changed
- Shader
  - 距離フェードにて、テクスチャで色を指定することができるようになりました。
- GUI
  - Unity2022 の Material Variant に対応しました。

### Fixed
- Other
  - asmdef を整理しました。autoReferenced = false に設定したため、Udon等をコンパイルするときにUnlitWFもコンパイルされることがなくなりました。

----

## 2023-08-27 (1.4.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20230827

### Added
- Shader
  - Gem に Emission を追加しました。EmissiveScroll と EmissiveAudioLink も使用可能です。

### Changed
- Shader
  - 逆光補正しない オプションを Lit Advance から ToonShade および RimLight に移動しました。
  - Custom/Tess_PowerCap と Custom/PowerCap_Outline の機能を整理しました。
- Tool
  - メニュー WFマテリアルに変換 を改良しました。変換前のマテリアルの状態に応じて変換するかどうかを選べるようになりました。

----

## 2023-07-10 (1.3.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20230710

### Added
- Shader
  - Nearクリップを無視する設定を追加しました。有効の場合、カメラのNearクリップ値に関わらず描画されます。
    - この設定はプロジェクト毎の設定項目です。WFEditorSettings.asset から有効無効を切り替えることができます。

### Changed
- Shader
  - Outline_Transparent 系にも背景消去パス (CLR_BG) を追加しました。
  - Mobile 系にも Emissive AudioLink を追加しました。
- GUI
  - Questワールド向けにビルドした際にUnlitWF系シェーダを自動でQuest対応シェーダに置き換える機能が、前回(UnlitWF_Shader_20230625) リリースでは壊れて動かなかった問題を修正しました。

----

## 2023-06-25 (1.2.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20230625

### Added
- Shader
  - CameraDepthTexture のみ描画する専用のシェーダ WF_UnToon_DepthOnly を追加しました。
  - 一部の Transparent シェーダについて、RenderQueue 2500 以下で描画するときは背景を消去するようにしました。
    - 背景消去を使用できるシェーダは、所定の条件にて 背景消去パスが有効化されます とメッセージが表示されます。

### Changed
- Shader
  - 半透明系の ShadowCaster のカットアウト値を調整できるようにしました。影のカットアウトしきい値 から設定できます。

### Fixed
- GUI
  - Hierarchy に Unload された Scene が残っている場合、シーン内マテリアル検索の処理がエラーを吐いていたのを修正しました。
    - これにより特定のツールと UnlitWF を同じプロジェクトで使用した際、VRCアバターのビルド時にエラーが出ていた問題が修正されます。

----

## 2023-06-03 (1.1.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20230603

### Changed
- Shader
  - UnToon Mobile の Opaque, TransCutout, Outline_Opaque, Outline_TransCutout に ShadowCaster を追加しました。
  - Metallic でRoughnessマップを使用していない場合は処理を省略して軽量化を図りました。

### Deprecated
- Shader
  - 削除予定の機能を使用している場合は警告を表示するようにしました。今回警告が追加されたのは次の機能です。
    - 3chカラーマスク
    - Metallic の Metallicマップの種類

----

## 2023-05-06 (1.0.0)
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/UnlitWF_Shader_20230506

### Changed
- Tool
  - 他シェーダから変換した際に CullMode と ZWrite を引き継ぐようにしました。
  - テンプレート適用まわりの動作を改善しました。コピー先プロパティが揃っている場合はシェーダを変更しないようにしました。

### Fixed
- Shader
  - URP/Unity2021 で DepthPrimingMode を有効にしていたときに描画されない問題を修正しました。
- GUI
  - Light Matcap をコピー＆ペーストする際、Light Matcap 2 以降の Matcap 設定値もコピーされてしまっていた問題を修正しました。

----

## 2023-04-01
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20230401

### Changed
- Shader
  - WF_UnToon_Custom_Transparent_FrostedGlass の見た目を改良しました。
  - オーバーレイ機能に「UV外の扱い」設定項目を追加しました。
- Tool
  - 他シェーダから変換した際にアウトラインの引き継ぎを改良しました。
  - 他シェーダから切り替えた際に VRCFallback タグがオーバーライドされている場合はクリアするようにしました。

### Fixed
- Shader
  - Water/Surface の Refraction が GPU Instancing に対応していなかったのを修正しました。

----

## 2023-02-25
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20230225

### Added
- Shader
  - UnToon, FakeFur, Gem に Dissolve 機能を追加しました。
    - ただし UnToon の Mobile, Custom, Legacy は追加の対象外です。

### Fixed
- Shader
  - Cutout系シェーダの alpha が想定していない出力結果となっていたのを修正しました。

----

## 2023-02-04
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20230204

### Added
- Shader
  - VRC Mirror Reflection と連携する水シェーダ Water/Surface/Custom/Mirror を追加しました。
  - 水シェーダに光源の反射を追加する Water/FX_Sun と Water/FX_Lamp を追加しました。
  - 水シェーダに Cutout 版を追加しました。

### Changed
- GUI
  - インスペクタのドロップダウンも日本語化するようにしました。
  - matcapタイプ の表記を 加算・減算 加算 乗算 にしました。挙動は以前の表記 MEDIAN_CAP LIGHT_CAP SHADE_CAP から変更ありません。

----

## 2023-01-07
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20230107

### Added
- GUI
  - VRCSDK3_Worlds + Android 環境でシーンビルドした際、Quest 非対応の UnlitWF のシェーダを使っているマテリアルは自動で Quest 対応の UnlitWF シェーダにフォールバックするようになりました。
  - マテリアルインスペクタ最上部の Variant から、Custom および Legacy 系の UnlitWF シェーダにも切り替えることができるようになりました。
- Tool
  - シーン内の UnlitWF マテリアルに対する警告(or情報)を一覧表示するウィンドウを作りました。Tools/UnlitWF/シーン内のマテリアルを検査 からご利用ください。

### Changed
- Shader
  - 2Pass を使用している Transparent 系シェーダの ZWrite パラメータが、以前は OFF/ON の2択でしたが、OFF/ON/TwoSided の3択になりました。
    - TwoSided を選択すると、表面と裏面の両方の ZWrite が ON として描画されます。
    - OFFとONの動作は以前と変化ありません。
  - Water/Surface/TransparentRefraction の Refraction に ノーマルマップ強度 を追加しました。波面に対するエフェクトの強度をより柔軟に調整できます。
    - 以前のバージョンで作成したマテリアルでは、この値は 1.0 になっています。新しいデフォルト値は 0.1 のため適宜調整してください。

### Fixed
- Shader
  - Water/Surface/TransparentRefraction にて、屈折により画面外の影が画面内に映り込んでしまう現象を修正しました。これと同時に UnToon/Custom/Refracted も修正されています。

----

## 2022-12-17
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20221217

### Added
- Shader
  - 水シェーダシリーズ WF_Water を追加しました。

### Changed
- Shader
  - Grass に側面消去の処理を入れてみました。
- GUI
  - Transparent なマテリアルが RenderQueue 2500 未満を使用しているときに警告を出すようにしました。
  - 両面描画なのに DoubleSidedGI が付いていないときに警告を出すようにしました。
- Tool
  - インポート時のダイアログの文言を変更しました。

----

## 2022-10-22
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20221022

### Added
- Shader
  - Emissive AudioLink を追加しました。(Mobile 版を除く UnToon 系に)
  - WF_Grass_TransCutout シェーダを追加しました。
- Tool
  - Editor 向け、ライトマップを一時的に非表示にする機能を追加しました。(ショートカット CTRL + ALT + L)

### Changed
- GUI
  - シェーダ切り替え時に同名シェーダがプロジェクト内に存在する場合、Assets/## Unlit_WF_ShaderSuite 内のシェーダが優先されるようにしました。
- Tool
  - Migration 時にシェーダの CurrentVersion を参照して、新しすぎる変更を行わないようにしました。

### Fixed
- Tool
  - クリンナップおよびマイグレーションの処理時間を短縮しました。

----

## 2022-09-23
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20220923

### Added
- Shader
  - すりガラス (くもりガラス) 用シェーダ UnlitWF/Custom/WF_UnToon_Custom_Transparent_FrostedGlass を追加しました。

### Changed
- GUI
  - Inspector 上部にあるシェーダ切り替え用プルダウンを調整しました。
  - Inspector の Color にカラーコードの TextField を追加しました。
- Tool
  - クリンナップツールを整理しました。
    - VRCSDK3 Avatars でビルドした際には、アバター配下の UnlitWF マテリアルを自動でクリンナップするようにしました。
    - ツールからクリンナップした場合、UnlitWF ではないマテリアルについては未使用プロパティの除去のみを行うようにしました。

### Fixed
- GUI
  - プロパティ値をリセットしたとき、デフォルト割り当てテクスチャも None になっていたので、デフォルト割り当てされるように修正しました。
  - Inspector で特定環境下において文字がめちゃくちゃ小さくなってしまう問題を修正しました。

----

## 2022-08-13
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20220813

### Added
- GUI
  - リムライトのマスクテクスチャにメインテクスチャを設定する APPLY ボタンを追加しました。
- Tool
  - メニュー項目を日本語化できるようにしました。Tools → UnlitWF → 「メニューの言語を日本語にする」から切り替えることができます。
  - ワールド向け用途として DirectionalLight の方向をマテリアルに記録するツールを追加しました。
    - VRCSDK3World 導入環境でのみメニューに出現します。

### Fixed
- Shader
  - ライトベイクにて Emission が機能していなかった問題を修正しました。
- Tool
  - Standard および Unlit から「UnlitWF のマテリアルに変換する」したときの変換精度を上げました。

----

## 2022-06-15
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20220615

### Added
- Shader
  - ディテールノーマルマップを DetailNormalMap として NormalMap から独立させました。
  - BackFace Texture で UV2 を使えるようになりました。
  - ToonShade の「境界のぼかし強度」を1影2影3影別に設定できるようになりました。
  - 逆光条件で距離が離れているときに影を弱める「距離フェード」機能を追加しました。

### Changed
- Tool
  - 他シェーダから UnlitWF に切り替えたとき、マテリアルカラーが維持されるようにしました。
  - ビルド時に古いマテリアルがある場合には警告を出すようにしました。

----

## 2022-05-29
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20220529

### Fixed
- Shader
  - FakeFur の ファーのランダム化 にて、時間経過でファーが揺れてしまう問題を修正しました。
  - 2019URP を Unity2021 + URP 環境で使用したときにエラーとなっていた箇所を修正しました。
  - Unity2020 から導入された Caching Preprocessor 使用時に警告が出てきた問題を修正しました。

----

## 2022-05-21
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20220521

### Changed
- Shader
  - FakeFur の毛先をバラつかせるパラメータ ランダム化 を追加しました。
  - FakeFur の入出力データを整理し ファーの枚数 を最大 6 にすることができるようになりました。
  - UnToon の Metallic Secondary の キューブマップ混合タイプ から ADDITION を削除しました。
  - UnToon の RimLight の 強度(上) の初期値を 0.1 から 0.05 に変更しました。
  - LODGroup の DitheringCrossFade に対応しました。LODGroup を使用した場合にディザリングクロスフェードを行います。
- GUI
  - Convert UnlitWF Material で他シェーダからマテリアルを変換する際、影色の変換アルゴリズムを変更しました。
- Other
  - DebugView を改良しました。ライト関係の表示を無くしたかわりに、表面・裏面を表示する Facing や、各種テクスチャをそのまま表示するテクスチャビュー機能を追加しました。

----

## 2022-04-17
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20220417

### Changed
- Shader
  - Matcap を単色化して適用するオプションを追加しました。
  - 2nd Normal Map を UV2 ベースで使用することができるようになりました。
  - Lit Advance にある『太陽光のモード』に CUSTOM_WORLD_POS を追加しました。指定のワールド座標に光源があるように動作します。
- GUI
  - Matcap を設定した際、テクスチャファイル名から LIGHT_CAP か MEDIAN_CAP かを判別して設定するようにしました。

----

## 2022-03-12
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20220312

### Added
- Shader
  - 光沢を追加する ClearCoat シェーダを追加しました。UnlitWF/Custom/WF_UnToon_Custom_ClearCoat_* にて使用いただけます。
  - 2枚目の Matcap を使えるようにしました。(PowerCap は従来どおり 8 枚まで使えます)

### Changed
- GUI
  - Editor Language の初回設定方法を改良しました。初めて使用する場合には OS の「国と地域」の設定を参照して、エディタに使用する言語を自動で選択します。

### Fixed
- Shader
  - FakeFur が SinglePassStereo (Instanced) 環境でエラーとなっていた問題を修正しました。

----

## 2022-02-13
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20220213

### Fixed
- Shader
  - VRC/Quest で使用したときに、Metallic, Emission, Matcap が無効になってしまう問題を修正しました

----

## 2022-01-23
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20220123

### Fixed
- GUI
  - VRCにアップロードした際、エフェクトが無効になり Unlit のような見た目になってしまう問題を修正しました。

----

## 2022-01-17
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20220117

### Changed
- Shader
  - 影コントラストを調整しない オプションを付けました
  - FakeFur_Mix の ファーの枚数 を Cutout 側と Transparent 側で変更できるようにしました

### Fixed
- Shader
  - GrabTexture が SinglePassStereo(Instancing) で使えなかったのを修正しました

----

## 2021-12-04
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20211204

### Added
- Shader
  - 屈折の使用できる透過シェーダ UnlitWF/WF_UnToon_Transparent_Refracted を追加しました。
  - ミラー内だけ or ミラー外だけ描画するシェーダ UnlitWF/Custom/WF_UnToon_Custom_MirrorControl_Opaque を追加しました。
    - MirrorControl は現在 Opaque だけですが、需要がありそうならば Transparent などの他の RenderMode の追加、あるいは本線への機能追加も検討しています。
  - VRC の新しい Shader Blocking System に対応して、VRCFallback タグの追加を全てのシェーダに行いました。

### Changed
- Shader
  - NormalMap の「影」を加減算合成から乗算合成に変えました。
    - この変更により、特に明度の低い箇所にかかる陰影は、以前のバージョンより薄くなります。
    - この変更は NormalMap の「影の濃さ」のみ変更されます。Matcap や ToonShade への影響は変化ありません。
  - 機能名 Decal Texture を Overlay Texture に変更しました。変更されたものは機能名だけで設定値などは変化ありません。

### Fixed
- Shader
  - 前回の更新 Unlit_WF_ShaderSuite_20211106 でエンバグした問題を修正しました。
    - Mobile 系のシェーダで 2nd CubeMap が動かなかった問題を修正しました。
    - ライトマップを使用した場合に、ライトマップが多重に適用されてしまう問題を修正しました。

----

## 2021-11-06
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20211106

### Added
- Shader
  - DistanceFade 機能が追加されました。
  - DecalTexture で UV スクロールを行えるようになりました。
- Tool
  - インポート時、プロジェクト内から UnlitWF のマテリアルをスキャンしてアップグレードするダイアログが表示されるようになりました。
    - 実行すると、WF マテリアルがプロジェクト内からスキャンされ、最新バージョンに対応した設定値へと変換されます。
    - 手動でスキャンさせる場合は Tools/UnlitWF/Migration All Materials を実行してください。
  - Hierarchy を右クリックして CleanUp Material Property から、そのアバターで使用しているマテリアル全てをクリンナップすることができるようになりました。

### Changed
- Shader
  - 重い分岐処理をシェーダキーワードに切り出したことで、軽量化されました。
  - マスクテクスチャ系について、使用しているチャンネルを記載するようにしました。(例: マスクテクスチャ (RGB))
- GUI
  - 韓国語の辞書が追加されました。한국어 버전이 추가되었습니다. 번역은 @SYARU_VR님 께서 맞아 주셨습니다! 한국어로 전환하시려면 머티리얼 에디터 하단의 Editor Language에서 '한국어'를 선택해주세요. 번역의 오류가 보이면 위 트위터 계정으로 DM주시면 감사하겠습니다. 잘 부탁드립니다!

----

## 2021-10-16
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20211016

### Changed
- GUI
  - ビルド時の使用マテリアル検索が少しリッチになりました。
    - VRCSDK3 の Playable Layers にて再生される AnimationClip が差し替えるマテリアルも、シーン内に含まれるマテリアルにカウントされるようになりました。
    - つまり AnimationClip でマテリアルを差し替える場合も、正しくビルドされるようになりました。

### Fixed
- Shader
  - DecalTexture 機能にて、頂点カラーをテクスチャorマスクテクスチャに乗算するチェックボックスが正しく動作していなかったので修正しました。

----

## 2021-09-23
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20210923

### Added
- Shader
  - FakeFur に、ファー部分の色味を調整する「色調整」パラメタを追加しました。合わせて項目定義順を並び替えています。
  - Anbient Occlusion の OcclusionMap が使用するUVを、UV1とUV2から選択できるようになりました。
  - Decal Texture の UV モードに MATCAP を追加しました。追加で1枚の matcap を様々な合成モードで使えるようになりました。
  - URP版シェーダに、以下のシェーダを追加しました。
    - WF_UnToon_Outline_Opaque
    - WF_UnToon_Outline_TransCutout
    - WF_UnToon_Mobile_Outline_Opaque
    - WF_UnToon_Mobile_Outline_TransCutout
    - WF_FakeFur_TransCutout
    - WF_FakeFur_Transparent
    - WF_FakeFur_FurOnly_TransCutout
    - WF_FakeFur_FurOnly_Transparent

### Changed
- Shader
  - ToonShadeの1影2影の初期値を、影色自動設定にて設定される値と合わせました。以前と比べて初期値が淡い影になります。
- Tool
  - Convert UnlitWF material での1影2影テクスチャの割当方法を改良しました。

### Fixed
- Shader
  - 特定のワールドで、存在しないはずの Realtime Point Light を拾って明るくなってしまう問題を修正しました。
  - EDGEアウトラインを特定角度から見たときにノコギリ状に見える問題を修正しました。

----

## 2021-09-05
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20210905

### Added
- Tool
  - VRC Quest (ワールド) 向けシェーダに一括で切り替える変換ツールを追加しました。マテリアル右クリック → UnlitWF Material Tools → Change Mobile shader から利用できます

### Fixed
- Shader
  - Quest (GLES3) 環境にて Lightmap を使った場合にシェーダエラーが起きる問題を修正。
- GUI
  - インスペクタに Double Sided Global Illumination のチェックボックスが出てくるように修正。
- Tool
  - 他シェーダから切り替える Convert UnlitWF material にて、幾つか判定ミスが起きる問題を修正。

----

## 2021-08-28
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20210828

### Added
- Shader
  - ファーのみ描画する FakeFur_FurOnly シェーダを追加しました。
  - Mobile 版でアウトラインを描画できる Mobile_Outline シェーダを追加しました。
- GUI
  - マテリアルの設定値をテンプレートとして保存、呼び出して適用できる Material Template 機能を追加しました。
  - Copy&Paste メニューを追加しました。
- Tool
  - 他シェーダから UnlitWF/UnToon に「雑に」切り替える Change UnlitWF Material 機能を追加しました。
  - シーン上にマテリアルの参照を保持できる Keep Materials in the Scene 機能を追加しました。

----

## 2021-07-31
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20210731

### Changed
- Shader
  - Unity 2019.4.29f1 に最適化した UnlitWF/UnToon を用意しました。
    - Unity2018.4.20f1 にて使用するための unitypackage と、Unity2019.4.29f1 で使用するための unitypackage の、2種類を用意しました。お手持ちの環境に合わせて選択してください。

----

## 2021-07-03
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20210703

### Changed
- Shader
  - UnToon に BackFace Texture 機能を追加しました。カリングオフで両面描画するとき、表面と裏面で異なるテクスチャおよび色を使えるようになりました。
  - UnToon_Mobile の Metallic でも CubeMap を使えるようにしました。
  - FakeFur のノーマルマップサンプリングを geom から vert に変更したので、負荷が若干軽くなったのではと思います。

----

## 2021-06-11
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20210611

### Changed
- Shader
  - FakeFur シリーズに WF_FakeFur_Mix を追加しました。(thanks ma1on!)
  - ノーマルマップの設定に ミラーXY反転 を付けました。
    - これは以前に存在した タンジェント反転 を置き換える機能です。

----

## 2021-05-15
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20210515

### Fixed
- Shader
  - FakeFur のライト取得方法を調整しました。Realtime Point Light 環境下でファーだけ暗くなる問題が修正されたかもしれません。
  - WF_UnToon_Outline_TransCutout だけリムライトが出なかった問題を修正しました。
  - 3ch Color Mask のアルファ値指定が Transparent3Pass で無視されていた問題を修正しました。
- GUI
  - Mobile 系の影色指定がインスペクタに出ていなかったので、ちゃんと出てくるよう修正しました。

----

## 2021-05-01
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20210501

### Added
- Shader
  - メタリックに Geometric Specular Antialiasing を追加しました。凹凸したメッシュでの金属光沢がちらちらしなくなりました。
  - AmbientOcclusion に 色調整 (Tint Color) パラメータを追加しました。AOマップの色味を微調整できます。
  - WF_UnToon_OutlineOnly_Transparent_MaskOut を追加しました。LineOnly 系でステンシルを使う場合に使用します。
  - URP 版 UnToon に WF_UnToon_Mobile_TransparentOverlay を追加しました。

----

## 2021-03-28
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20210328

### Changed
- Shader
  - アウトラインが EDGE のとき、特定角度から見た場合に線がノコギリ状になってしまう問題を修正しました。
  - MetallicSmoothnessMap の種類を MASK と METALLIC から選択できるようにしました。MASK の場合は従来と同じ挙動になります。METALLIC は Standard シェーダと同じように金属・非金属パラメータがスペキュラ色に影響するようになります。
  - ラメのフェードアウト距離を MinMaxSlider にしました。
  - Decal Texture に頂点カラーを影響させる設定を追加しました。

### Fixed
- Shader
  - ミラー内かつ逆光条件のとき、アンチシャドウマスクを入れたメッシュ(顔など)に視差問題が出てしまう問題を修正しました。

----

## 2021-02-28
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20210228

### Changed
- Shader
  - TriShade にて追加した「3影設定」を、1影～3影まで可変にして UnToon 本線でも使えるようにしました。
  - TriShade にて追加した「ToonFog」を、UnToon 本線 (なお Basic と Mobile は除く) でも使えるようにしました。
  - MatcapShadows のころにあった「Matcap ベース色」パラメタを復活させました。
  - FakeFur の影の計算式を調整しました。暗めのワールドで濃いめに描画されてしまっていたところを、自然な感じになるようにしました。
- GUI
  - 最新バージョンを web からチェックし、古いバージョンのシェーダを使用している場合はメッセージを表示するようにしました。
  - 2nd Normal Map (Detail Normal) の細かさを設定する「粗く」「細かく」ボタンを追加しました。
  - その他、項目ごとにちょっと便利な機能を盛り込み (例えば NormalMap 未設定のときには「ノーマルマップ強度」パラメータを非表示にする、など)

----

## 2021-01-20
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20210120

### Changed
- Shader
  - テセレーションの処理を見直しました。
    - テセレーションタイプのパラメータを削除し、以前は DISTANCE として存在した「カメラとの距離で分割強度を決定する」の固定としました。
    - テセレーションのフェードアウト距離を設定できるようパラメータを追加しました。デフォルトでは 0.5 以下が分割MAX、2.0 以上が分割なし、その中間をフェードアウト範囲として動作します。
    - スムーズマスク を追加しました。部位によってスムーズ強度を変更させることができ、これによってハードエッジのポリゴン割れを防止できるようになりました。
  - リムライトの処理を見直しました。
    - 強度(マスター) パラメータを追加し、縦横の強度を一括で調整できるようになりました。以前からあった 強度(上)、強度(横)、強度(下) も引き続き利用できます。
    - 境界のぼかし強度 パラメータを追加しました。
    - 混合タイプの、従来の ADD 設定値を ADD_AND_SUB に名称変更し、新たに単純な加算合成を行う ADD を追加しました。
  - ライトベイク時の微調整を行う機能 Light Bake Effects を追加しました。間接光の色味や明度、エミッションの強度をマテリアルごとに微調整できます。
- GUI
  - Batching Static 付き MeshRenderer から使用されているマテリアルであると検出された場合『Batching Static 用の設定に変更しますか？』と表示するようになりました。既に設定されている場合は何も表示しません。
  - 一部のパラメータについて、インスペクターGUIを最適化しました。

### Fixed
- Shader
  - ライトの色味を計算する式の誤りを修正しました。これにより橙色のライトが黄色に扱われてしまい、本来より緑色成分が強くなってしまっていた問題が修正されます。

----

## 2021-01-01
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20210101

### Added
- Outline のみ描画するシェーダ WF_UnToon_OutlineOnly_Transparent を追加しました。
- Lame のみ描画するシェーダ WF_UnToon_Custom_LameOnly_Transparent を追加しました。
- Lame と Emission に 透明度も反映する プロパティを追加しました。チェックを入れるとベースのアルファ値をオーバーライドします。
- Lame を UV1 と UV2 のどちらで描画するか選べるようになりました。

### Changed
- Shader
  - FakeFur のプロパティ物理名が内部的に誤っていたので修正しました。Fix Now が出たら押しておいてください。
- GUI
  - 現在のシェーダバージョンを ShaderGUI に表示するようにしました。(最上部にある Current Version)
- Tool
  - Copy Material Properties ツールを機能強化しました。

----

## 2020-12-13
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20201213

### Added
- Shader
  - UnToon に「ラメ」を追加しました。
  - Metallic の 2nd Cube Map にて、最大光量を制限する「2nd CubeMap Hi-Cut Filter」パラメータを追加しました。

### Changed
- Shader
  - Alphaブレンドの処理を見直し。
  - UnToon_URP が SRPBatcher に完全対応しました(たぶん)。

----

## 2020-11-19
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20201119

### Added
- Shader
  - 3chカラーマスクに対応しました。
  - Decal Texture に ANGEL_RING モードを追加しました。また、選択可能な混合タイプを増やしました。
  - アウトラインだけを描画するシェーダ (OutlineOnly) を追加しました。
  - UniversalRP (LightweightRP) 用のシェーダを試作しました。Core_URP.unitypackage をお試しください。

----

## 2020-10-13
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20201013

### Added
- Shader
  - アウトラインに Custom Color Texture を使えるようになりました。
  - 頂点カラーをブレンドできるようになりました。
  - TransCutout に Alpha To Coverage を適用できるようになりました。縁にMSAAによるアンチエイリアスが掛かるようになりました。

### Changed
- Shader
  - NormalMap のサンプラーステートを MainTex から分離し、独自定義にすることにしました。MainTex は Bilinear のまま NormalMap を Trilinear にすることができます。
  - TransCutout を従来は表裏の2パスで描画していたところを、1パスで描画するように変更しました。(たぶん2パスにする意味がなかったので。そのぶん軽量化されました)

### Fixed
- Shader
  - アウトライン付き Cutout でアウトラインが Cutout されていなかった問題を修正
  - Tess の Transparent3Pass のアウトラインが Tess されていなかった問題を修正

----

## 2020-09-18
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20200918

### Added
- Shader
  - RimLight に BlendNormal パラメータを追加しました。

### Changed
- Shader
  - 不透明シェーダとして以前は _Texture と命名していたものを、_Opaque に変更しました。(例: WF_UnToon_Texture → WF_UnToon_Opaque)
  - UnToon_Mobile について、Matcap の使える版と Metallic の使える版が別々だった点を見直し、ひとつのシェーダとして統合しました。その影響で MobileMetallic は削除されています。
  - UnlitWF/Gem および UnlitWF/FakeFur を作り直ししました。後方互換性の無くなっている箇所が一部あります。マテリアルの再設定をおねがいします。

### Fixed
- GUI
  - DebugView のマテリアルを複数選択して編集ができなかった問題を修正しました。
  - DebugView からの切り戻し時に、元マテリアルの RenderQueue 値を再設定するよう修正しました。
- Tool
  - MaterialTools の Migration が上手く動作していなかった問題を修正しました。

----

## 2020-08-30
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20200830

### Added
- GUI
  - デバッグ用シェーダ WF_DebugView のカスタムインスペクタを用意しました。だいぶ使いやすくなったと思います。

### Changed
- Shader
  - アウトラインマスクが、今まではアウトラインの透明度として反映していたところを、このバージョンからはアウトラインの太さに反映されるようにしました。
  - Metallic の「モノクロ反射」が、今まではチェックボックスでのON/OFFだったところを、0～1の範囲型に変更しました。

### Fixed
- Shader
  - 特定の条件下において Transparent_MaskOut がうまく Transparent_Mask を透過できていなかった問題を修正しました。

----

## 2020-08-06
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20200806

### Added
- Shader
  - デバッグ用シェーダの WF_DebugView を追加
  - Custom シェーダを2種追加
    - UnlitWF/Custom/WF_UnToon_Custom_Tess_PowerCap_Texture
    - UnlitWF/Custom/WF_UnToon_PowerCap_Outline_Texture
- Tool
  - Copy Property ツールでコピー可能な項目を追加
  - Reset Property ツールで Alpha リセット＆Litリセットを追加

### Fixed
- Shader
  - アウトラインとEmissionのZシフトする算出式が一部誤っていたので修正(カメラに近づける方向に移動するとき誤った位置に移動されていた)
- Tool
  - Copy Property ツールで Texture がコピーできていなかった不具合を修正

----

## 2020-07-06
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20200706

### Changed
- Shader
  - MetallicSmoothnessMap に加えて RoughnessMap も併用できるように改良しました
  - Matcap に 視差(Parallax) の設定項目を追加しました
  - ScreenTone Texture を Decal Texture に名称変更して、貼り付け先の UV を UV1, UV2, SKYBOX から選べるようにしました
  - Emissive Scroll の方向を LOCAL_SPACE と WORLD_SPACE から選べるようにしました

----

## 2020-06-04
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20200604

### Changed
- GUI
  - アルファマスクテクスチャを設定したとき、Alpha Source を MASK_TEX_RED に自動で変更する
  - シェーダ切り替えボタンを追加

### Fixed
- Shader
  - VRで両眼視したときに Tessellation が暴れる問題を修正
  - 鏡の中で逆光になったときに Anti-Shade 掛けている顔などが暗くならなかった問題を修正
- Tool
  - Migration material ツールで処理後に明示的に SaveAsset するよう修正

----

## 2020-05-14
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20200514

### Changed
- Shader
  - TransCutout 系シェーダの Cast Shadow が想定通りではなかった問題を修正しました。
- GUI
  - Secondary NormalMap と Secondary CubeMap のテクスチャをセットしたとき、これらの機能が OFF になっていた場合はエディタが自動的に ON に変更するようになりました。

### Fixed
- GUI
  - CustomShaderGUI が重かったので軽量化しました。編集が便利になりました。

----

## 2020-04-11
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20200411

### Changed
- Shader
  - Tessellation のタイプを選択できるようになりました。従来までの「カメラとの距離に応じて細分化」の他に、「辺の長さが一定になるように細分化」と「固定の数だけ細分化」を選択できます。
  - Disable BasePos (メッシュ原点を取得しない) プロパティを追加しました。Batching static にて原点が移動してしまう場合などにチェックしてください。
- Other
  - VRChatでのUnityバージョン変更に伴い、推奨バージョンを Unity 2017.4.28f1 から Unity 2018.4.20f1 に変更しました
  - unitypackage を Unity2018 で再パッケージングしました。meta や prefab なども合わせて変更しています。
  - テクスチャ類に Streaming Mipmaps を付与しました。そのままVRCアバターとしてアップロード可能です。

----

## 2020-03-09
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20200309

### Changed
- Shader
  - gles3環境でビルドに失敗する問題を修正。UsePassとFallBackの再調整。
    - 対応環境に STYLY を追加しました。UnToon を使用した場合マテリアル変更することなく各種環境で動作します。WebGL環境ではFallBackが作動し、より低負荷の描画を行います。
  - Anti-Glare(まぶしさ防止)のパラメータを整理し、Darken(暗さの最低値), Lighten(明るさの最大値) の2パラメタに再編しました。
    - 旧パラメタにて BRIGHT や OFF を使用していた場合、Darken(暗さの最低値) の値をより大きなものに設定してください。
  - アウトラインをベース色と混合させるパラメタは、以前はアウトライン色のAlphaで調整していましたが、ベース色混合パラメタを新たに用意しました。

----

## 2020-02-01
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20200201

### Added
- Shader
  - アウトラインに EDGE モードを用意しました。ハードエッジにやたらと強いアウトラインになります。
  - UnToon_Mobile でもメタリックを使いたくて WF_UnToon_Mobile_Texture_Metallic などを追加しました。

### Fixed
- Shader
  - UnToon を全面的に書き直しました。コードが整理され負荷が軽くなりました。
    - アウトラインの使えるシェーダは UnToon_Outline 内に集約整理しました。
    - これにあわせてWF_UnToon_Texture からはアウトライン機能が削除されました。アウトラインを使用する場合は WF_UnToon_Outline_Texture を使用してください。
    - メタリックマスクが MetallicSmoothness マップに機能強化されました。マスクテクスチャのAlphaを参照するようになったため見た目に差が生じる場合があります。
    - Emissive Scroll のスクロール方向がローカル座標からワールド座標に変更されました。スクロール方向の再設定が必要な場合があります。
    - DebugView が一時的に削除されました。今後シェーダ内に組み込むのではなく専用のデバッグ用シェーダとして追加する予定があります。
    - これにあわせて Shader Keyword が再び0個になりました。
  - 整理により、マテリアルの再設定が必要な場合があります。Tools/UnlitWF/Migration material から、複数マテリアルの一括変換も可能です。


----

## 2019-12-22
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20191222

### Added
- Shader
  - UnToon に Metallic Specular を追加
  - WF_UnToon_Mobile_TransparentOverlay を追加

### Changed
- Shader
  - Outline と EmissiveScroll の ZShift がモデルスケールだったところをワールドスケールに変更
  - WF_Gem に ZWrite 設定を追加

### Fixed
- Shader
  - WF_UnToon_Mobile_TransCutout が Cutout していなかった問題を修正

----

## 2019-11-26
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20191126

### Added
- Shader
  - UnToon の matcap に SHADE_CAP (乗算モードで影を合成するためのモード) を追加
  - UnToon_PowerCap_Transparent3Pass を追加
  - Transparent3Pass 系の EmissiveScroll を調整

----

## 2019-10-27
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20191027

### Fixed
- Shader
  - Tessellation の HeightMap UV が MainTex UV と同期していなかった問題を修正
  - Tessellation の Outline 無効時、裏面メッシュが描画されてしまっていた問題を修正

----

## 2019-09-27
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190927

### Changed
- Shader
  - リムライトの混合モードを ADD と ALPHA から選べるようにしました
  - リムライト色に HDR を使えるようにしました
  - アウトラインの描画方法を変更
- GUI
  - カスタムインスペクタを ShrikenHeader に対応させました

----

## 2019-09-14
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190914

### Added
- Shader
  - オクルージョン(AOマップ)に対応しました。Ambient Occlusion の設定から有効化できます。
  - ライトベイクに対応しました。Ambient Occlusion が有効化されていて、オブジェクトが lightmap static になっている場合に、ライトマップを読み込みベイク結果を反映します。
  - 太陽光のモードを選択できるようになりました。従来の AUTO に加えてメイン光源方向をカスタマイズできるようになりました。
  - ScreenTone Texture を追加しました。以前 MatcapShadows では Overlay Texture の名称で備えていた機能で、視差問題などを解消して復活となりました。
- GUI
  - デバッグモードを追加しました。法線やライトマップなどをデバッグ表示できます。

----

## 2019-08-24
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190824

### Added
- Shader
  - UnToon に "Flip Tangent" を追加しました。ノーマルマップ適用時、左右が反転してしまう場合にお試しください。
- GUI
  - シェーダGUIを日本語対応にしました。マテリアルインスペクタの一番下から「English」「日本語」を選択できます。

### Fixed
- Shader
  - 顔と身体が別メッシュのとき、影の濃さが異なってしまう問題を修正しました。

----

## 2019-08-09
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190809

### Added
- Shader
  - WF_Gem_Transparent を追加しました。UnToon ベースの Gem Shader です。
  - Unlit_WF_UnToon_PowerCap_Texture を追加しました。Matcap を最大8枚使えるバリアントです。

----

## 2019-07-13
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190713

### Added
- Shader
  - FakeFur を再構成、Fur Static Vector が復活しました。
  - UnToon の半透明系に、Fresnel Power を追加しました。ガラスなどの表現が豊かになりました。
- GUI
  - UnToon の影色を自動設定する Shade Color Suggest ボタンを追加しました。

### Fixed
- Shader
  - VRC_Mirror 越しに UnToon を見たとき、影色がちらつく問題を修正しました。
  - 黒色ライト環境下にてテクスチャが真っ黒になってしまう問題を修正しました。(Lit Color Blend で黒色をブレンドしてしまっていた)

----

## 2019-06-26
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190626

### Added
- Shader
  - Secondary NormalMap (Detail NormalMap) を使用できるようになりました
  - Secondary Metallic (2nd CubeMap) を使用できるようになりました
  - Lightmap Static チェック時に Lightmap を参照するようになりました
  - GPUインスタンシングに対応しました
  - WebGL で使用できる軽量の Mobile 版 UnToon を追加しました
  - Tessellation (PhongTess および DisplacementHeightMap) を使用できる Tess 版 UnToon を追加しました

----

## 2019-06-01_ForVket3
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190601_ForVket3

### Added
- Tool
  - マテリアルの編集を行うツールを追加しました。メインメニュー "Tools/UnlitWF/MaterialTools" から使用してください。マテリアル設定値の「コピー」「クリンナップ」「リセット」が行えます。

### Changed
- Shader
  - カメラ方向・ライト方向の判定を、各頂点から行うのではなく常にメッシュ原点から行うように変更しました。メッシュの場所によって陰色に差が出る問題が改善されました。
  - "1st Shade Power" と "2nd Shade Power" を統合し、陰の強さを一括で設定する "Shade Power" に 変更しました。この項目では1陰2陰のバランスを変えることはできなくなりましたが、かわりに各色の強さを A 値で設定することができるようになりました。

### Fixed
- Shader
  - MatcapShadows が VRC アップロード後に Standard シェーダに置き換わってしまう問題を修正しました。具体的にはシェーダ名に /Legacy/ と付けるのを止めて、/MatcapShadows/ とするようにしました。
  - FakeFur が特定の環境でエラーとなってしまう問題を修正しました。具体的には TEXCOORD が重複していたのを修正しました。

----

## 2019-05-18
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190518

### Changed
- Shader
  - FakeFur を UnToon ベースで作り直しました。FakeFur でも階調陰を使うことができるようになりました。
  - グレースケール化係数の調整。係数を BT709 から BT601 に変更しました。輝度計算にて緑の重みが従来よりも小さくなり、赤と青の重みが大きくなりました。
  - Transparent_Outline_3Pass を追加しました。
  - NormalMap に BumpScale を追加しました。ノーマルマップの凹凸サイズを微調整できます。
  - Metallic に BlendType を追加しました。従来ではリフレクションプローブの乗算合成のみ可能でしたが、設定により加算合成も可能になりました。黒いアルベドに対する映り込みの描写能力が向上しました。

### Fixed
- Shader
  - UnToon のステンシル関係が全く動作していなかったので、ちゃんと動くように修正しました。
  - マテリアルプレビューでの陰に関する問題を修正しました。
  - 暗いワールドでアウトラインが暗くなっていなかった問題を修正しました。

----

## 2019-05-04
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190504

### Deprecated
- Shader
  - MatcapShadows を "UnlitWF/Legacy" に移動しました

### Fixed
- Shader
  - MatcapColor がうまく反映されていなかった問題を修正
  - 逆光判定がモデル回転の影響を受けていた問題を修正

----

## 2019-04-27
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190427

### Fixed
- Shader
  - UnToon の TransCutout および Transparent3Pass で、ShadowCaster が Cutoff Threshold をうまく計算できていなかった問題を修正

----

## 2019-04-13
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190413

### Changed
- Shader
  - 明るい下地に EmissiveScroll を乗せてもよく見えるようになりました。白色にも EmissiveScroll を乗せることができます。
  - アルファスクロールのマスク指定方法を「マスク画像のAチャンネル」から「マスク画像のRGBチャンネルの最大値」に変更しました。つまりマスク画像で黒色の部分は、アルファスクロールでも変化しません。
  - UnToon_Transparent3Pass の EmissiveScroll を『貫通型 EmissiveScroll』に変更しました。服メッシュを貫通して肌に描かれた EmissiveScroll が見えるようになりました。

### Fixed
- Shader
  - UnToon の影 (ShadowCaster) が正しく落ちなかった問題を修正
  - UnToon_TransCutout のアウトラインがアルファマスクを無視していた問題を修正
  - UnToon に _Color プロパティを追加。Color は Main Texture に乗算されます

----

## 2019-03-31
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190331

### Changed
- Shader
  - ToonShade を強化、UV に応じて影色を設定できるようになりました。

### Fixed
- Shader
  - TransCutout のアウトラインにアルファが考慮されていなかった問題を修正。

----

## 2019-03-24
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190324

### Fixed
- Shader
  - NormalMap がうまく出てくれていなかった問題を修正しました。
  - 真上から DirectionalLight に照らされているときに影がちらつくのを軽減しました。
  - ToggleNoKwd を Unity 標準の Toggle に戻しました。Shader Keyword は削減したままです。

----

## 2019-03-17
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190324

### Added
- Shader
  - EmissiveScroll を追加
  - 半透明 Cast Shadow と Outline を追加
  - Transparent3Pass を追加
  - Metallic に Specular を追加

### Changed
- Shader
  - Shader Keyword の廃止：大人数のワールドに join しても、他シェーダと競合したり機能不全に陥ることがなくなりました

----

## 2019-03-10_UnToon_Beta
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190310_UnToon_Beta

### Added
- Shader
  - UnlitWF シリーズの新作として "UnToon" シェーダを追加しました。shader 選択から UnlitWF/WF_UnToon_*にてご利用いただけます。

----

## 2019-03-07
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190307

### Changed
- Shader
  - 負荷対策(shader keyword の削減)のため、内部ロジックを変更しました。

----

## 2019-02-16
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190216

### Added
- Shader
  - WF_MatcapShadows_ColorFade の追加：WF_MatcapShadows_Color の透過対応版を追加しました

### Changed
- Shader
  - EmissiveScroll の調整：従来よりもより輝くようになりました

----

## 2019-01-14
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20190114

### Changed
- Shader
  - Single Pass Stereo Rendering (Instanced) に部分対応

----

## 2018-12-31
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20181231

### Changed
- Shader
  - FakeFur 側も Color Change に反応するよう変更

### Fixed
- Shader
  - 特定の角度から見たときに Matcap が暴走する不具合を修正(ver:20181218での不具合)

----

## 2018-12-18
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20181218

### Changed
- Shader
  - カメラを回転させても Matcap が回転しないようにしました

----

## 2018-12-14
https://github.com/whiteflare/Unlit_WF_ShaderSuite/releases/tag/Unlit_WF_ShaderSuite_20181214

### Added
- Shader
  - MatcapShadow_Transparent_MaskOut_Blend シェーダを追加しました。ステンシルマスク部分を半透明合成します。瞳に半透明の髪がかかるような効果が得られます。
  - Overlay Texture の座標系を MAINTEX_UV と VIEW_XY から選択できるようになりました。前者はUVスクロールします。後者は従来通りのスクリーン座標系でのスクロールです。

### Changed
- Shader
  - MatcapShadow_Transparent_MaskOut の ZWrite をデフォルトでONに変更しました。

### Fixed
- Shader
  - FakeFur_Transparent 抜け毛問題(ver: 20181201～20181202 でのバグ)を解決、Skybox を背景にしても毛が正しく描画されるように修正しました。合わせて他のシェーダも設定を見直ししています。
  - EmissiveScroll のマスクがモノクロで使われていた問題(ver: 20181127～20181202 でのバグ)を修正しました。EmissiveScroll のマスクはフルカラー対応しています。
  - Overlay Texture の視差に関する問題を修正。

