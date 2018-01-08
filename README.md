# seena-tan

[![Greenkeeper badge](https://badges.greenkeeper.io/ginpei/seena-tan.svg)](https://greenkeeper.io/)

# Set up for development

```console
git clone git@github.com:ginpei/seena-tan.git
cd seena-tan
cp bin/env.example bin/env
chmod u+x bin/env
source bin/env && npm start
```

Do not forget to run `source bin/env` before running script.

# Test

```console
source bin/env && npm test
```

## Filtering

```console
source bin/env && npm test -- -g Timer
```
