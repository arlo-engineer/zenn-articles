# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

Zenn（zenn.dev）の記事・本を管理するリポジトリ。Zenn CLI を Docker コンテナ内で動かして執筆・プレビューを行う。

## 開発コマンド（すべて Makefile 経由）

```bash
# 初回セットアップ
make build        # Docker イメージをビルド
make package.ci   # npm ci で依存パッケージをインストール

# プレビューサーバー起動（http://localhost:8000）
make up

# プレビューサーバー停止
make down

# 新規記事作成（ランダムなスラッグで articles/ 配下に生成される）
make article
```

## コンテンツ構成

- `articles/` — 記事ファイル（Markdown + YAML frontmatter）
- `books/` — 本ファイル
- `images/` — 記事から参照する画像（`/images/<記事スラッグ>/` で整理）

## 記事の frontmatter 形式

```yaml
---
title: "記事タイトル"
emoji: "🐘"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["topic1"] # タグ（配列）
published: false # true で公開
---
```

## やってほしいこと

- 堅苦しくない文章として欲しい。人間が書いているような、多少崩れた言い回しとしてください

## やってはいけないこと

- AI特有の太字や水平線の使用
