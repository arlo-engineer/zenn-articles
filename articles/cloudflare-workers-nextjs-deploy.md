---
title: "Cloudflare Workers × Next.js で手軽に高速デプロイする方法"
emoji: "🚀"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Next.js","Cloudflare","deploy"]
published: true
---
## はじめに
できる限り運用コストを抑えて個人開発を行いたいという思いから、商用利用でも費用のかからないCloudflare Workersへのデプロイを実施しました。日本語の文献が少なく、公式ドキュメントの内容だと不足していると感じた箇所があったため、記事を書きました。

以下は、記事を書くにあたって参考にした公式ドキュメントです。
https://opennext.js.org/cloudflare/get-started

## 前提
- 本記事では、GUI（管理画面）ではなく、CLI（コマンドライン）を使用したデプロイ方法を解説します。
- R2バケットは使用しません。
- Next.jsのアプリケーションがローカル環境で動作していることが前提です。
- Cloudflareのアカウントが作成されていることが前提です。
- Supabaseを利用したフルスタックアプリケーションもデプロイ可能です。
- Next.js v14ではデプロイが確認しましたが、v15については未確認です。


## デプロイ手順

### 1. @opennextjs/cloudflare をインストール
```bash
npm install @opennextjs/cloudflare@latest
```

### 2. Wragler CLIのインストール
Cloudflare Workersのデプロイに使うCLIツール「Wrangler」をインストールします。
バージョンは v3.99.0 以降が必要です。
```bash
npm install --save-dev wrangler@latest
```

### 3. `open-next.config.ts`と`wrangler.jsonc`の作成
以下のコマンドを実行し、設定ファイルを作成します。2つの設問に対して、`Yes`と回答します。
```bash
npx opennextjs-cloudflare build

✔ Missing required `open-next.config.ts` file, do you want to create one? (Y/n) · true
✔ No `wrangler.(toml|json|jsonc)` config file found, do you want to create one? (Y/n) · true
```

### 4.`wrangler.jsonc`の編集（R2なし）
今回はR2バケットを使用しないため、以下の通りコメントアウトします。
```json:wrangler.jsonc
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "main": ".open-next/worker.js",
  "name": "postabit",
  "compatibility_date": "2025-05-10",
  "compatibility_flags": ["nodejs_compat", "global_fetch_strictly_public"],
  "assets": {
    "directory": ".open-next/assets",
    "binding": "ASSETS"
  }
  // "r2_buckets": [
  // Use R2 incremental cache
  // See https://opennext.js.org/cloudflare/caching
  // {
  // "binding": "NEXT_INC_CACHE_R2_BUCKET",
  // Create the bucket before deploying
  // You can change the bucket name if you want
  // See https://developers.cloudflare.com/workers/wrangler/commands/#r2-bucket-create
  // "bucket_name": "cache"
  // }
  // ]
}
```

### 5. `open-next.config.ts`の編集（R2なし）
今回は、R2バケットを使用しないため、以下の通り、コメントアウトします。
```js:open-next.config.ts
// default open-next.config.ts file created by @opennextjs/cloudflare
import { defineCloudflareConfig } from '@opennextjs/cloudflare/config';
import r2IncrementalCache from '@opennextjs/cloudflare/overrides/incremental-cache/r2-incremental-cache';

export default defineCloudflareConfig({
  // incrementalCache: r2IncrementalCache,
});
```

### 6. `.dev.vars`の追加
環境変数を`.env.local`から読み込むため、以下のように`.dev.vars`を作成します。
```:.dev.vars
NEXTJS_ENV=development
```

### 7. package.jsonにスクリプトを追加
```json:package.json
"scripts": {
  "preview": "opennextjs-cloudflare build && opennextjs-cloudflare preview",
  "deploy": "opennextjs-cloudflare build && opennextjs-cloudflare deploy",
  "upload": "opennextjs-cloudflare build && opennextjs-cloudflare upload",
  "cf-typegen": "wrangler types --env-interface CloudflareEnv cloudflare-env.d.ts"
}
```
**各スクリプトの用途**
- preview: Cloudflare 環境でローカル実行
- deploy: 本番環境へデプロイ
- upload: デプロイせずにアップロードのみ
- cf-typegen: 環境変数の型定義生成

### 8. 静的アセットのキャッシュ設定
`pulic/_headers`ファイルを作成し、以下を記述します。
```:public/_headers
/_next/static/*
  Cache-Control: public,max-age=31536000,immutable
```

### 9. .gitignoreの編集
以下ディレクトリ/ファイルはGit管理から除外します。
```:gitignore
.open-next
.wrangler/
.dev.vars
```

### 10. プレビュー環境で動作確認
以下を実行し、Cloudflareを使ったローカルプレビューを確認できます。この環境を使用し、デプロイ前の動作確認を行うと良いと思います。
```bash
npm run preview
```

### 11. 実際にデプロイする
```bash
npm run deploy
```

## トラブルシューティング
- `.open-next/worker.js` が生成されないエラー
```
✘ [ERROR] The entry-point file at ".open-next/worker.js" was not found.
```
このエラーは、**Cloudflare の GUI（管理画面）からデプロイを試みた際に発生**しました。  
本記事ではあくまで **CLI（コマンドライン）を使ったデプロイ方法** を解説しており、GUIによる手順は対象外です。  
そのため、GUIでのデプロイに関しては対応方法が明確にはわかっていませんが、もし解決方法をご存知の方がいらっしゃれば、ぜひコメントで教えていただけると助かります。

同様の事象は以下のスレッドでも報告されています。
https://www.answeroverflow.com/m/1368219516449853481


## 参考文献
- https://developers.cloudflare.com/pages/framework-guides/nextjs/ssr/get-started/#related-resources
- https://zenn.dev/masa5714/articles/fbc046a556a892
