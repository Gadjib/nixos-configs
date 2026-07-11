# JSON, YAML, API

## Назначение

`jq`, `yq`, `httpie`, `curl`, `wget` помогают читать API, форматировать JSON/YAML и скачивать файлы.

## jq

```bash
jq . file.json
jq '.field' file.json
jq '.items[]' file.json
jq '.items[] | select(.enabled == true)' file.json
jq '.items | map(.name)' file.json
curl -s URL | jq .
```

## yq

```bash
yq . file.yaml
yq '.services.web.image' docker-compose.yml
yq '.items[] | select(.name == "x")' file.yaml
```

## httpie

```bash
http GET https://example.com
http POST https://example.com/api name=ilya
http GET https://example.com Authorization:"Bearer TOKEN"
http --headers GET https://example.com
```

## curl

```bash
curl https://example.com
curl -I https://example.com
curl -H 'Accept: application/json' https://example.com | jq .
curl -O https://example.com/file.tar.gz
curl -L -o file URL
curl -X POST -H 'Content-Type: application/json' -d '{"x":1}' URL
```

## wget

```bash
wget URL
wget -c URL
wget -O file URL
```

## Частые ошибки

- Не quoted JSON в shell.
- Забыли `-L` для redirects в curl.
- Pipe to `jq` падает, потому что ответ не JSON.

## Cheatsheet

```bash
jq . file.json
yq . file.yaml
http GET URL
curl -s URL | jq .
wget -c URL
```
