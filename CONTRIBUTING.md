# Contributing to Puppy Stardew Server

鎰熻阿鎮ㄥPuppy Stardew Server椤圭洰鐨勫叧娉紒

## 濡備綍璐＄尞

### 鎶ュ憡Bug

鍦ㄦ彁浜ug鍓嶏紝璇凤細

1. **鎼滅储鐜版湁Issue** - 纭闂鏈鎶ュ憡
2. **鏀堕泦淇℃伅**锛?
   - 瀹屾暣鐨勯敊璇棩蹇楋細`docker logs nothing-stardew > logs.txt`
   - Docker鐗堟湰锛歚docker --version`
   - 鎿嶄綔绯荤粺淇℃伅
   - docker-compose.yml閰嶇疆锛堝垹闄ゆ晱鎰熶俊鎭級
3. **鍒涘缓Issue** - 浣跨敤Bug妯℃澘

### 鎻愪氦鍔熻兘璇锋眰

璇疯鏄庯細
- 鍔熻兘鐨勫叿浣撶敤閫?
- 涓轰粈涔堥渶瑕佽繖涓姛鑳?
- 鍙兘鐨勫疄鐜版柟妗堬紙鍙€夛級

### 鎻愪氦Pull Request

1. **Fork椤圭洰**
2. **鍒涘缓鍔熻兘鍒嗘敮**锛歚git checkout -b feature/my-feature`
3. **寮€鍙戝苟娴嬭瘯**
4. **鎻愪氦鍙樻洿**锛氶伒寰彁浜よ鑼冿紙瑙佷笅鏂囷級
5. **鎺ㄩ€佸埌Fork**锛歚git push origin feature/my-feature`
6. **鍒涘缓Pull Request**

## 寮€鍙戠幆澧冭缃?

```bash
# 1. Clone浠撳簱
git clone https://github.com/nothing3ok/stardew-server.git
cd stardew-server

# 2. 璁剧疆Steam鍑瘉锛堢敤浜庢祴璇曪級
export STEAM_USERNAME="your_test_account"
export STEAM_PASSWORD="your_password"

# 3. 鏋勫缓娴嬭瘯闀滃儚
docker build -t test-stardew:dev -f docker/Dockerfile docker/

# 4. 杩愯娴嬭瘯
./tests/test-steam-guard.sh
```

## 浠ｇ爜瑙勮寖

### Shell鑴氭湰

```bash
# 鉁?濂界殑瀹炶返
function_name() {
    local variable="$1"

    if [ -z "$variable" ]; then
        log_error "Variable is empty"
        return 1
    fi

    echo "$variable"
}

# 鉂?閬垮厤
# - 涓嶅姞寮曞彿鐨勫彉閲忥細echo $variable
# - 浣跨敤set -e鑰屼笉鏄樉寮忛敊璇鐞?
# - 娌℃湁鍑芥暟灏佽鐨勯暱鑴氭湰
# - 缂哄皯娉ㄩ噴鐨勫鏉傞€昏緫
```

### Dockerfile

```dockerfile
# 鉁?濂界殑瀹炶返
RUN apt-get update && \
    apt-get install -y package && \
    rm -rf /var/lib/apt/lists/*

# 鉂?閬垮厤
# - 鍒嗗紑鐨凴UN鍛戒护锛堝鍔犲眰鏁帮級
# - 涓嶆竻鐞哸pt缂撳瓨
# - 浣跨敤latest鏍囩锛堟棤鐗堟湰鎺у埗锛?
```

### 鎻愪氦瑙勮寖

```
绫诲瀷(鑼冨洿): 绠€鐭弿杩?

璇︾粏鎻忚堪锛堝彲閫夛級

鍏宠仈Issue: #123
```

**绫诲瀷锛?*
- `feat`: 鏂板姛鑳?
- `fix`: Bug淇
- `docs`: 鏂囨。鏇存柊
- `refactor`: 閲嶆瀯
- `test`: 娴嬭瘯鐩稿叧
- `chore`: 鏋勫缓/宸ュ叿鐩稿叧

**绀轰緥锛?*
```
fix(entrypoint): remove pipe to fix stdin blocking

Steam Guard input was blocked by pipe redirection.
Removed '| tee' to preserve stdin for user input.

Fixes: #42
```

## 娴嬭瘯瑕佹眰

鎻愪氦PR鍓嶈纭繚锛?

- [ ] 浠ｇ爜閫氳繃鍩烘湰娴嬭瘯
- [ ] 娣诲姞浜嗗繀瑕佺殑娉ㄩ噴
- [ ] 鏇存柊浜嗙浉鍏虫枃妗?
- [ ] 娴嬭瘯浜哠team Guard娴佺▼锛堝鏋滀慨鏀逛簡entrypoint.sh锛?
- [ ] 娴嬭瘯浜嗘ā缁勫姞杞斤紙濡傛灉淇敼浜嗘ā缁勯厤缃級

### 杩愯娴嬭瘯

```bash
# Steam Guard娴嬭瘯
./tests/test-steam-guard.sh

# 閮ㄧ讲楠岃瘉
./verify-deployment.sh

# 娓呯悊娴嬭瘯鐜
./tests/cleanup-tests.sh
```

## 鏂囨。瑕佹眰

淇敼浠ｇ爜鏃讹紝璇峰悓鏃舵洿鏂帮細

- **DEVELOPMENT.md** - 寮€鍙戞枃妗?
- **README.md** - 鐢ㄦ埛鏂囨。
- **浠ｇ爜娉ㄩ噴** - 澶嶆潅閫昏緫鐨勮鏄?

## 闂鎺掓煡

閬囧埌闂锛熸煡鐪嬶細

1. **DEVELOPMENT.md** - 甯歌闂鎺掓煡
2. **GitHub Issues** - 宸茬煡闂
3. **Docker logs** - `docker logs nothing-stardew`

## 琛屼负鍑嗗垯

- 灏婇噸鎵€鏈夎础鐚€?
- 淇濇寔璁ㄨ涓撲笟鍜屽缓璁炬€?
- 鎺ュ彈寤鸿鎬ф壒璇?
- 鍏虫敞椤圭洰鏈€浣冲埄鐩?

## 璁稿彲璇?

鎻愪氦璐＄尞琛ㄧず鎮ㄥ悓鎰忔寜鐓ч」鐩殑MIT璁稿彲璇佹巿鏉冩偍鐨勮础鐚€?

## 鑱旂郴鏂瑰紡

- **Issues**: https://github.com/nothing3ok/stardew-server/issues
- **Docker Hub**: https://hub.docker.com/r/truemanlive/nothing-stardew-server

---

鎰熻阿鎮ㄧ殑璐＄尞锛侌煄?
