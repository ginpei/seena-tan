# seena-tan

[![Build Status](https://travis-ci.org/ginpei/seena-tan.svg?branch=master)](https://travis-ci.org/ginpei/seena-tan)
[![Greenkeeper badge](https://badges.greenkeeper.io/ginpei/seena-tan.svg)](https://greenkeeper.io/)

# Set up for development

```console
$ git clone git@github.com:ginpei/seena-tan.git
$ cd seena-tan
$ cp .env.example .env
```

Edit `.env` as you need then:

```console
$ npm start
```

# Test

```console
npm test
```

## Filtering

Use `--` and `-g xxx`.

```console
npm test -- -g Timer
```
