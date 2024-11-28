---
title: "内部結合(INNER JOIN)と外部結合(OUTER JOIN)の違い"
emoji: "✨"
type: "tech"
topics:
  - "sql"
published: true
published_at: "2024-07-10 22:06"
---

## INNER JOINとOUTER JOINの違い
- INNER JOINとOUTER JOINの比較
  INNER JOINは、両方のテーブルに共通する行のみを結合するもの。
  OUTER JOINは、片方または両方のテーブルにデータが存在する場合に結合するもの。
  
    | INNER JOIN | OUTER JOIN |
    |:-----------:|:------------:|
    | ![](https://storage.googleapis.com/zenn-user-upload/b2588f31eba9-20240710.png)| ![](https://storage.googleapis.com/zenn-user-upload/0ad54b220289-20240710.png)|
    | ```INNER JOIN users ON users.id = professions.id```      | ```OUTER JOIN users ON users.id = professions.id```      |