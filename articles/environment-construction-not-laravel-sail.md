---
title: "Dockerを使用したLaravelの開発環境構築手順【Laravel Sailなし】"
emoji: "🪣"
type: "tech"
topics:
  - "docker"
  - "laravel"
  - "dockerfile"
  - "環境構築"
published: true
published_at: "2024-07-24 08:46"
---

## 1. はじめに
今回はDockerを使ったLaravelの環境構築について学んだので、その備忘録を残しておきます。
Dockerでの環境構築には、公式ドキュメントでおすすめされているLaravel Sailを使った方法もあります。Laravel Sailを使用した環境構築もコマンドで手軽にできるので良いのですが、デプロイする際にDockerfileやdocker-compose.yml、.env等を書き換える必要があるため中々の手間であることに気がつきました。
※初心者ゆえに、誤った情報が含まれている可能性もありますが、ご了承ください。もし間違いに気づかれた方は、ぜひコメントで教えていただけると嬉しいです。

### 対象者
- PHPの学習を終え、Laravelの学習に入ろうとしている方
- MAMP/XAMPでは環境構築できたが、Dockerを使用した環境構築をしたい方
- Laravel Sailを使って環境構築できたが、1からDockerを使用した環境構築をしたい方
- Dockerの基礎は抑えている方

### 前提条件
- ある程度基礎的なDockerの知識があること
  Dockerfileやdocker-compose.ymlの定義や書き方をある程度理解していればOK
  上記の知識がない方は、以下記事を参考にしてみてください。特に1つ目はおすすめで、Rubyの環境構築ですが、Dockerを使用しない古典的な環境構築とDockerを使用したモダンな環境構築の両方をハンズオン形式で実践し、Dockerの素晴らしさや使い方を学ぶことができます。付随してLinuxやネットワークの知識も身につくのでおすすめです。
  @[card](https://www.udemy.com/course/docker-from-linux-and-networking/)
  @[card](https://youtu.be/dbIdWVFWF5Q?si=6UMcc-1oMSqf-9t0)
- Docker Desktopがインストールされていること
  インストール方法はMacOSとWindowsOSで異なる点に注意してください。
  @[card](https://matsuand.github.io/docs.docker.jp.onthefly/desktop/mac/install/)
  @[card](https://matsuand.github.io/docs.docker.jp.onthefly/desktop/windows/install/)
  
### Dockerとは？
Dockerは、アプリケーションを開発、配布、実行するためのオープンプラットフォームです。

主な特徴：
- **コンテナ化**：アプリケーションとその依存関係を1つのユニットにパッケージ化
- **ポータビリティ**：どの環境でも同じように動作
- **軽量**：仮想マシンよりも少ないリソースで動作
- **スケーラビリティ**：コンテナの複製と管理が容易

### Laravelとは？
Laravelは、PHPのWebアプリケーションフレームワークです。

主な特徴：
- MVC（Model-View-Controller）アーキテクチャ
- 強力なORM（Eloquent）
- 簡単なルーティング
- テンプレートエンジン（Blade）
- 認証、セッション、キューなどの機能が組み込み済み

## 2. Docker環境でLaravelを使用する利点

1. **環境の一貫性**
   - 開発、テスト、本番環境を同一に保つことができる
   - "自分のマシンでは動作するけれど、他人のマシン/サーバーでは動作しない"問題を解消

2. **簡単なセットアップ**
   - 新しいプロジェクトの環境構築が迅速に行える
   - チーム全体で同じ開発環境を共有しやすい

3. **依存関係の管理**
   - PHPバージョン、拡張機能、データベースなどの依存関係をコンテナ内で管理
   - プロジェクトごとに異なる設定を持つことが可能

4. **スケーラビリティ**
   - 必要に応じてサービス（データベース、キャッシュなど）を追加・削除が容易
   - 本番環境のスケールアップ/ダウンが容易

5. **開発ワークフローの改善**
   - コードの変更をすぐに反映できる
   - 環境の再構築が簡単で高速

6. **CI/CDとの親和性**
   - 継続的インテグレーション/デリバリーパイプラインに組み込みやすい
   - テストの自動化が容易

7. **ローカルリソースの節約**
   - 必要なサービスだけを起動することでリソースを節約
   - 複数のプロジェクトを同時に扱いやすい

8. **バージョン管理**
   - Dockerファイルをバージョン管理することで、環境の変更履歴を追跡可能

9. **セキュリティ**
   - コンテナ化により、アプリケーション間の分離が強化される
   - 本番環境に近い構成でセキュリティテストが可能

## 3. 全体像
### 開発環境イメージ
今回作成するコンテナと使用するポート、ファイル配置などの大まかな全体像は以下の通りです。
![](https://storage.googleapis.com/zenn-user-upload/f188352213b3-20240723.png)

### 環境構築手順
1. Dockerfileとdocker-compose.ymlを使用してWeb3階層モデル(Nginx, PHP, MariaDB)を作成する
2. PHPのコンテナにアクセスし、Laravelをインストールする
3. docker-compose.ymlを編集し、ブラウザでLaravelの初期画面が表示されることを確認する

### ディレクトリ構造の概要
典型的なDocker化されたLaravelプロジェクトの構造は以下の通りです。
```
php-nginx-mariadb/
│
├── docker-config/
│   ├── nginx/
│   │   ├── default.conf
|   |   └── Dockerfile
│   └── php/
│       ├── Dockerfile
│       └── php.ini
├── .env                    # Docker環境変数の設定ファイル
├── docker-compose.yml      # Docker Composeの設定ファイル
├── README.md               # プロジェクトの説明書
└── my-app/                 # Laravelプロジェクトのルートディレクトリ
    ├── app/
    ├── bootstrap/
    ├── config/
    ├── database/
    ├── public/
    ├── resources/
    ├── routes/
    ├── storage/
    ├── tests/
    ├── vendor/
    ├── .env
    └── ...
```

## 4. 具体的な手順
### Nignxコンテナの作成
1. 以下を実行し、任意のディレクトリを作成する
    ```bash:
    mkdir php-nginx-mariadb
    ```
2. 以下を実行し、先ほど作成したディレクトリに作業ディレクトリを移動する
   ```bash:
   cd php-nginx-mariadb
   ```
3. 以下を実行し、nginxディレクトリを作成する
   ```bash:
   mkdir nginx
   ```
4. nginxディレクトリ配下に、Dockerfileファイルを作成し、以下の通り記述する
   ```Dockerfile:Dockerfile
    FROM alpine:3.6
    RUN apk update && \
        apk add --no-cache nginx
    RUN mkdir -p /run/nginx
    CMD nginx -g "daemon off;"
   ```
5. nginxディレクトリ配下に、default.confファイルを作成し、以下の通り記述する
   ```conf:default.conf
    server {
        listen 80;
        server_name localhost;
        root /var/www/public;
        index index.php index.html;
        allow all;
        client_max_body_size 10000M;
    
        access_log /var/log/nginx/ssl-access.log;
        error_log  /var/log/nginx/ssl-error.log;
    
        location / { 
            root /var/www/public;
            try_files $uri $uri/ /index.php$is_args$args;
        }
    
        location ~ \.php$ {
            try_files $uri =404;
    
            #502
            
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass web:9000;
            fastcgi_index index.php;
    
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $fastcgi_path_info;
   
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods "POST, GET, OPTIONS";
            add_header Access-Control-Allow-Headers "Origin, Authorization, Accept";
            add_header Access-Control-Allow-Credentials true;
        }   
    }
   ```

### PHPコンテナの作成
1. phpディレクトリ配下に、Dockerfileを作成し、以下の通り記述する
   ```Dockerfile:Dockerfile
    FROM php:8.1-fpm
    WORKDIR /var/www
    ADD . /var/www
    
    RUN chown -R www-data:www-data /var/www
    
    RUN cd /usr/bin && curl -s http://getcomposer.org/installer | php && ln -s /usr/bin/composer.phar /usr/bin/composer
    
    RUN apt-get update \
      && apt-get install -y \
      gcc \
      make \
      git \
      unzip \
      vim \
      libpng-dev \
      libjpeg-dev \
      libfreetype6-dev \
      libmcrypt-dev \
      libpq-dev \
      curl \
      gnupg \
      openssl \
      && docker-php-ext-install pdo_mysql mysqli \
      && docker-php-ext-configure gd --with-freetype --with-jpeg \
      && docker-php-ext-install -j$(nproc) gd \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*
    
    
    COPY php.ini /usr/local/etc/php/
    
    
    RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
      && apt-get update \
      && apt-get install -y nodejs \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* 
    
    RUN npm install -g n \
      && n stable \
      && npm update -g npm
   ```
2. phpディレクトリ配下に、php.iniを作成し、以下の通り記述する
    ```ini:php.ini
    [Date]
    date.timezone = "Asia/Tokyo"
    [mbstring]
    mbstring.language = "Japanese"
    post_max_size = 500M
    upload_max_filesize=500M
    [xdebug]
    ```
### docker-composeの作成
1. php-nginx-mariadb配下に.envファイルを作成し、以下を記述する
    ```.env:.env
    MYSQL_DATABASE=development
    MYSQL_ROOT_PASSWORD=root
    MYSQL_USER=mysql
    MYSQL_PASSWORD=mysql
    TZ=Asia/Tokyo
    ```
2. php-nginx-mariadb配下にdocker-compose.ymlファイルを作成し、以下を記述する
    ```yaml:docker-compose.yml
    services:
      web: 
        container_name: myapp-php
        build: ./docker-config/php
        ports:
          - '5173:5173'
        volumes:
          - .:/var/www/
        depends_on:
          - mariadb
    
      nginx:
        container_name: myapp-nginx
        image: nginx
        build: ./docker-config/nginx
        ports:
          - "81:80"
        volumes:
          - .:/var/www
          - ./docker-config/nginx/default.conf:/etc/nginx/conf.d/default.conf
        depends_on:
          - web
    
      mariadb:
        container_name: myapp-mariadb
        image: mariadb
        ports:
          - 3306:3306
        environment:
          MYSQL_DATABASE: ${MYSQL_DATABASE}
          MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
          MYSQL_USER: ${MYSQL_USER}
          MYSQL_PASSWORD: ${MYSQL_PASSWORD}
          TZ: ${TZ}
          
        volumes:
          - ./docker-config/mariadb/data:/var/lib/mysql
          - ./docker-config/mariadb/data/my.cnf:/etc/mysql/conf.d/my.cnf
          - ./docker-config/mariadb/data/sql:/docker-entrypoint-initdb.d
    ```

### Laravelのインストール
1. 以下を実行し、コンテナを起動する
   ```bash:
   docker-compose up -d
   ```
2. 以下を実行し、phpコンテナにアクセスする
   ```bash:
   docker exec -it myapp-php bash
   ```
3. 以下を実行し、Laravelをインストールする
   ```bash:
    composer create-project --prefer-dist laravel/laravel my-app
   ```
4. 以下を実行し、コンテナから出る
    ```bash:
    exit
    ```
5. docker-compose.ymlで記述されている、myapp-phpとmyapp-nginxのvalumesを以下の通り書き換える
    ```yml:docker-compose.yml
    - - .:/var/www/
    + - ./my-app:/var/www/
    ```
6. 以下を実行し、再度イメージの作成とコンテナの起動を行う
   ```bash:
   docker-compose up -d
   ```
### ブラウザでの確認
1. ブラウザでhttp://localhost:81にアクセスし、以下の通り表示されることを確認する
    ![](https://storage.googleapis.com/zenn-user-upload/e1ae9fa50726-20240723.png)

## 5. まとめ
各ファイルの記述方法や意味などは後々追記していこうと思います。また、今回の内容だけでは、DBへの接続ができないため、今後記事を書いていこうと思います。

## 6. 参考文献
@[card](https://www.kagoya.jp/howto/cloud/container/docker_laravel/)
@[card](https://qiita.com/hitotch/items/869070c3a9f474a358ea)