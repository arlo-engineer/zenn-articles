---
title: "GitHubからLaravelプロジェクトをローカル環境でセットアップする方法"
emoji: "😸"
type: "tech"
topics:
  - "github"
  - "laravel"
  - "php"
  - "mamp"
  - "clone"
published: true
published_at: "2024-08-22 19:33"
---

## 1. はじめに
- 本記事の概要と目的
    GitHubからLaravelプロジェクトをクローンし、ローカル環境で動作させるための基本的な手順を紹介します。

## 2. 必要な環境の準備
- ローカル開発に必要なツール
    - GitHubのアカウント
    - MAMP/XAMP
    - VSCode

## 3. 具体的な手順
### ① GitHubリポジトリのクローン
1. クローンしたいリポジトリの右上のCodeからURLをコピーする
![](https://storage.googleapis.com/zenn-user-upload/59953b2202a3-20240822.png)

2. MAMPのhtdocsディレクトリに移動し、コードをクローンする
```
cd /Applications/MAMP/htdocs
git clone [手順1で取得したURL]
```

### ② 依存パッケージのインストール
以下を順に実行し、composerとnpmをインストールする
```
composer install
npm install
```
### ③ phpMyAdminでデータベースを作成する
1. 以下ページからMAMP Websiteにアクセスする
![](https://storage.googleapis.com/zenn-user-upload/1dff3d355e70-20240822.png)
2. 新規作成をクリックして、DBを作成する
![](https://storage.googleapis.com/zenn-user-upload/2d0b89499a87-20240822.png)
3. 作成したDBに対してアクセスできるユーザーを作成する
### ④ 環境設定ファイルの作成と設定
1. .env.exampleファイルを複製して、.envファイルを作成する
2. 手順③で作成したDBとユーザー情報を元に以下の通り編集する
```:.env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=8889
DB_DATABASE=todo_list
DB_USERNAME=root
DB_PASSWORD=password
```
3. ターミナルで以下を実行し、DBとの接続を行う
```
php artisan migrate
```
※もし、以下のようなエラーが発生する場合は、手順2で入力した情報が間違えている可能性が高いため見直しをしてください。
![](https://storage.googleapis.com/zenn-user-upload/2daa5cd5d254-20240822.png)
### ⑤ ローカルサーバーの起動と動作確認
1. ターミナルで以下を実行し、Viteを起動する
```
npm run dev
```
2. ブラウザから以下にアクセスし、アプリが表示されていれば成功
http://localhost:8888/[プロジェクト名]/public

## 8. まとめ
今回は、GitHubからLaravelプロジェクトをクローンし、ローカル環境で動作させるための基本的な手順を紹介しました。DBへの接続に苦戦したため、設定した情報が正確かどうかしっかりと確認することが大切だと思います。
