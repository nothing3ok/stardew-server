# Development Guide

## 椤圭洰鏋舵瀯

### 鏍稿績缁勪欢

```
nothing-stardew-server/
鈹溾攢鈹€ docker/
鈹?  鈹溾攢鈹€ Dockerfile              # 闀滃儚鏋勫缓瀹氫箟
鈹?  鈹溾攢鈹€ mods/                   # 棰勮妯＄粍
鈹?  鈹?  鈹溾攢鈹€ AlwaysOnServer/     # 24/7杩愯妯＄粍
鈹?  鈹?  鈹溾攢鈹€ AutoHideHost/       # 鑷姩闅愯棌涓绘満妯＄粍
鈹?  鈹?  鈹斺攢鈹€ ServerAutoLoad/     # 鑷姩鍔犺浇瀛樻。妯＄粍
鈹?  鈹斺攢鈹€ scripts/
鈹?      鈹溾攢鈹€ entrypoint.sh       # 瀹瑰櫒鍚姩鑴氭湰锛堜富瑕侀€昏緫锛?
鈹?      鈹溾攢鈹€ log-monitor.sh      # 鏃ュ織鐩戞帶
鈹?      鈹溾攢鈹€ log-manager.sh      # 鏃ュ織杞浆
鈹?      鈹斺攢鈹€ view-logs.sh        # 鏃ュ織鏌ョ湅宸ュ叿
鈹溾攢鈹€ tests/                      # 娴嬭瘯鑴氭湰
鈹?  鈹斺攢鈹€ test-steam-guard.sh     # Steam Guard娴嬭瘯
鈹溾攢鈹€ quick-start.sh              # 涓€閿儴缃茶剼鏈?
鈹溾攢鈹€ verify-deployment.sh        # 閮ㄧ讲楠岃瘉鑴氭湰
鈹斺攢鈹€ docker-compose.yml          # Docker缂栨帓閰嶇疆
```

### 鍚姩娴佺▼

```
1. entrypoint.sh 鍚姩
   鈫?
2. 楠岃瘉Steam鍑瘉
   鈫?
3. 淇libcurl鍏煎鎬?
   鈫?
4. 涓嬭浇娓告垙锛堝鏋滈渶瑕侊級
   鈹溾攢鈫?闇€瑕丼team Guard锛?
   鈹?  鈹斺攢鈫?绛夊緟鐢ㄦ埛閫氳繃docker attach杈撳叆楠岃瘉鐮?
   鈹斺攢鈫?鐩存帴涓嬭浇
   鈫?
5. 瀹夎SMAPI
   鈫?
6. 澶嶅埗棰勮妯＄粍
   鈫?
7. 鍚姩Xvfb铏氭嫙鏄剧ず
   鈫?
8. 鍚姩VNC鏈嶅姟鍣紙鍙€夛級
   鈫?
9. 鍚姩鏃ュ織鐩戞帶锛堝彲閫夛級
   鈫?
10. 鍚姩娓告垙鏈嶅姟鍣紙./StardewModdingAPI --server锛?
```

## 鍏抽敭璁捐鍐崇瓥

### 1. Steam Guard澶勭悊

**v1.0.34鍙婁箣鍓嶇殑闂锛?*
```bash
# 鉂?閿欒锛氫娇鐢ㄧ閬撻樆鏂簡stdin
steamcmd.sh ... 2>&1 | tee /tmp/log
```

**v1.0.35淇锛?*
```bash
# 鉁?姝ｇ‘锛氱洿鎺ヨ繍琛岋紝淇濈暀stdin
steamcmd.sh ...
```

**鍘熺悊锛?*
- Bash绠￠亾浼氶噸瀹氬悜stdin鍒扮閬撹緭鍏ョ
- steamcmd闇€瑕佷粠缁堢璇诲彇楠岃瘉鐮?
- `docker attach`灏嗙敤鎴风粓绔繛鎺ュ埌瀹瑰櫒stdin
- 濡傛灉stdin琚閬撻樆鏂紝鐢ㄦ埛杈撳叆鏃犳硶鍒拌揪steamcmd

### 2. 鐢ㄦ埛鏉冮檺

- 瀹瑰櫒浠steam`鐢ㄦ埛锛圲ID 1000锛夎繍琛?
- 鏁版嵁鍗峰繀椤荤敱UID 1000:1000鎵€鏈?
- `init.sh`鑴氭湰璐熻矗鍒濆鍖栨潈闄?

### 3. 妯＄粍绠＄悊

**Always On Server锛?*
- 浣挎父鎴忓湪娌℃湁鐜╁鏃剁户缁繍琛?
- 閰嶇疆鏃堕棿娴侀€熴€佺潯鐪犳椂闂寸瓑

**AutoHideHost锛?*
- 鑷姩灏嗕富鏈虹帺瀹朵紶閫佸埌娌欐紶(0,0)
- 閬垮厤涓绘満瑙掕壊褰卞搷娓告垙浣撻獙

**ServerAutoLoad锛?*
- 鑷姩妫€娴嬪苟鍔犺浇Co-op瀛樻。
- 閲嶅惎鍚庤嚜鍔ㄦ仮澶嶆父鎴忕姸鎬?
- 鈿狅笍 宸茬煡闄愬埗锛氶渶瑕乂NC鎵嬪姩閲嶆柊鍔犺浇浠ュ垵濮嬪寲澶氫汉鏈嶅姟鍣?

## 寮€鍙戝伐浣滄祦

### 鏈湴娴嬭瘯

```bash
# 1. 鏋勫缓闀滃儚
cd /root/github-nothing-stardew
docker build -t test-stardew:dev -f docker/Dockerfile docker/

# 2. 杩愯娴嬭瘯瀹瑰櫒
docker run -it --rm \
  -e STEAM_USERNAME="test_user" \
  -e STEAM_PASSWORD="test_pass" \
  -e ENABLE_VNC=true \
  test-stardew:dev

# 3. 鏌ョ湅鏃ュ織
docker logs -f <container_id>
```

### 娴嬭瘯Steam Guard娴佺▼

```bash
export STEAM_USERNAME="your_username"
export STEAM_PASSWORD="your_password"
./tests/test-steam-guard.sh
```

### 楠岃瘉閮ㄧ讲

```bash
# 杩愯楠岃瘉鑴氭湰
./verify-deployment.sh

# 鎵嬪姩妫€鏌ュ叧閿寚鏍?
docker logs nothing-stardew | grep -i "error"
docker logs nothing-stardew | grep "mod loaded"
docker exec nothing-stardew ps aux | grep -i smapi
```

## 甯歌闂鎺掓煡

### Steam Guard鍗′綇

**鐥囩姸锛?* 杈撳叆楠岃瘉鐮佸悗鏃犲搷搴?

**鍘熷洜锛?* entrypoint.sh浣跨敤浜嗙閬擄紙`| tee`锛夛紝闃绘柇stdin

**瑙ｅ喅锛?* 浣跨敤v1.0.35+锛屽凡绉婚櫎绠￠亾

### 娓告垙涓嬭浇澶辫触

**鍙兘鍘熷洜锛?*
1. Steam API閫熺巼闄愬埗
2. 缃戠粶瓒呮椂
3. 纾佺洏绌洪棿涓嶈冻
4. 鏉冮檺闂锛圲ID涓嶆槸1000锛?

**鎺掓煡姝ラ锛?*
```bash
# 妫€鏌ョ鐩樼┖闂?
df -h

# 妫€鏌ユ潈闄?
ls -la data/

# 鏌ョ湅璇︾粏鏃ュ織
docker logs nothing-stardew 2>&1 | grep -A 10 "download"
```

### 妯＄粍鏈姞杞?

**妫€鏌ユ楠わ細**
```bash
# 1. 纭妯＄粍鏂囦欢瀛樺湪
docker exec nothing-stardew ls -la /home/steam/stardewvalley/Mods/

# 2. 鏌ョ湅SMAPI鏃ュ織
docker exec nothing-stardew cat /home/steam/.config/StardewValley/ErrorLogs/SMAPI-latest.txt

# 3. 妫€鏌ユā缁勯厤缃?
docker exec nothing-stardew cat /home/steam/stardewvalley/Mods/AutoHideHost/manifest.json
```

## 鍙戝竷娴佺▼

### 鐗堟湰鍙疯鑼?

- v1.0.X锛氳ˉ涓佺増鏈紙bug淇銆佸皬鏀硅繘锛?
- v1.X.0锛氭鐗堟湰锛堟柊鍔熻兘銆佹ā缁勬洿鏂帮級
- vX.0.0锛氫富鐗堟湰锛堥噸澶у彉鏇淬€佹灦鏋勬敼鍔級

### 鍙戝竷妫€鏌ユ竻鍗?

- [ ] 鏇存柊Dockerfile涓殑version鏍囩
- [ ] 鏇存柊CLAUDE.md涓殑鐗堟湰淇℃伅
- [ ] 娴嬭瘯Steam Guard娴佺▼
- [ ] 娴嬭瘯妯＄粍鍔犺浇
- [ ] 娴嬭瘯VNC杩炴帴
- [ ] 楠岃瘉鐜╁鑳藉杩炴帴
- [ ] 鏇存柊README.md锛堝鏈夋枃妗ｅ彉鏇达級
- [ ] Git鎻愪氦锛堜笉鍖呭惈AI鏍囪锛?
- [ ] 鏋勫缓Docker闀滃儚
- [ ] 鎺ㄩ€佸埌Docker Hub
- [ ] 鍒涘缓GitHub Release锛堝彲閫夛級

### 鍙戝竷鍛戒护

```bash
VERSION="1.0.36"

# 1. Git鎻愪氦
git add [files]
git commit -m "v${VERSION}: description"
git push origin main

# 2. 鏋勫缓闀滃儚
docker build -t truemanlive/nothing-stardew-server:v${VERSION} -f docker/Dockerfile docker/
docker tag truemanlive/nothing-stardew-server:v${VERSION} truemanlive/nothing-stardew-server:latest

# 3. 鎺ㄩ€佸埌Docker Hub
docker push truemanlive/nothing-stardew-server:v${VERSION}
docker push truemanlive/nothing-stardew-server:latest
```

## 浠ｇ爜瑙勮寖

### Shell鑴氭湰

```bash
# 1. 浣跨敤鏄庣‘鐨勯敊璇鐞嗭紙涓嶈鐢╯et -e锛?
if ! command; then
    log_error "Command failed"
    return 1
fi

# 2. 鎵€鏈夊彉閲忓姞寮曞彿
echo "$VARIABLE"

# 3. 浣跨敤鍑芥暟灏佽閲嶅閫昏緫
download_game() {
    local username="$1"
    # ...
}

# 4. 娣诲姞娉ㄩ噴瑙ｉ噴澶嶆潅閫昏緫
# This handles Steam Guard by preserving stdin
# 閫氳繃淇濈暀stdin澶勭悊Steam Guard
steamcmd.sh ...

# 5. 缁熶竴鏃ュ織鍑芥暟
log_info "Information message"
log_warn "Warning message"
log_error "Error message"
```

### Docker鏈€浣冲疄璺?

```dockerfile
# 1. 鍚堝苟RUN鍛戒护鍑忓皯灞傛暟
RUN apt-get update && \
    apt-get install -y package && \
    rm -rf /var/lib/apt/lists/*

# 2. 鍥哄畾鐗堟湰鍙?
RUN wget -qO smapi.zip 'https://.../SMAPI-4.3.2-installer.zip'

# 3. 浣跨敤闈瀝oot鐢ㄦ埛
USER steam

# 4. 娓呯悊缂撳瓨
RUN ... && rm -rf /tmp/*
```

## 鎬ц兘浼樺寲

### 璧勬簮浣跨敤

- **鍐呭瓨锛?* ~1.5-2GB锛堝熀纭€锛? 鐜╁鏁懊?00MB
- **CPU锛?* 1-2鏍稿績
- **纾佺洏锛?* ~2GB娓告垙鏂囦欢 + ~500MB SMAPI/mods
- **缃戠粶锛?* 涓婁紶 50-100 Kbps/鐜╁

### 浼樺寲寤鸿

1. 绂佺敤VNC鍙妭鐪亊50MB鍐呭瓨
2. 璋冩暣璧勬簮闄愬埗鍦╠ocker-compose.yml
3. 浣跨敤SSD鎻愬崌娓告垙鍔犺浇閫熷害
4. 鑰冭檻CDN鍔犻€熷鎴风杩炴帴

## 瀹夊叏鑰冭檻

### 鏁忔劅淇℃伅澶勭悊

- 鉂?姘歌繙涓嶈灏哠team鍑瘉鎻愪氦鍒癎it
- 鉁?浣跨敤鐜鍙橀噺浼犻€掑嚟璇?
- 鉁?.gitignore鍖呭惈.env鏂囦欢
- 鉁?CLAUDE.md鍦?gitignore涓?

### 瀹瑰櫒瀹夊叏

- 鉁?浠ラ潪root鐢ㄦ埛杩愯
- 鉁?鍙紑鏀惧繀瑕佺鍙?
- 鉁?浣跨敤鍙鎸傝浇锛堝鏋滃彲鑳斤級
- 鈿狅笍 瀹氭湡鏇存柊鍩虹闀滃儚

## 璐＄尞鎸囧崡

### 鎻愪氦Bug鎶ュ憡

璇峰寘鍚細
1. 瀹屾暣鐨刣ocker logs杈撳嚭
2. docker-compose.yml閰嶇疆
3. 绯荤粺淇℃伅锛圤S銆丏ocker鐗堟湰锛?
4. 澶嶇幇姝ラ

### 鎻愪氦鍔熻兘璇锋眰

璇疯鏄庯細
1. 鍔熻兘鎻忚堪
2. 浣跨敤鍦烘櫙
3. 棰勬湡琛屼负
4. 鍙€夊疄鐜版柟妗?

### Pull Request瑙勮寖

1. 鎻忚堪娓呮淇敼鍐呭
2. 鍖呭惈娴嬭瘯姝ラ
3. 鏇存柊鐩稿叧鏂囨。
4. 閬靛惊浠ｇ爜瑙勮寖

## 鏈潵鏀硅繘璁″垝

### 鐭湡锛堝凡瀹屾垚鉁擄級

- [x] 淇stdin闃绘柇闂
- [x] 绠€鍖杄ntrypoint.sh閫昏緫
- [x] 娣诲姞閮ㄧ讲楠岃瘉鑴氭湰
- [x] 鍒涘缓Steam Guard娴嬭瘯鑴氭湰

### 涓湡锛堣繘琛屼腑锛?

- [ ] 妯″潡鍖杄ntrypoint.sh锛堟媶鍒嗕负澶氫釜鍑芥暟锛?
- [ ] 娣诲姞鑷姩鍖栨祴璇旵I/CD
- [ ] 鏀硅繘閿欒娑堟伅锛堟洿鍙嬪ソ鐨勬彁绀猴級
- [ ] 缁熶竴鏃ュ織鏍煎紡

### 闀挎湡锛堣鍒掍腑锛?

- [ ] 鏀寔澶氭灦鏋勶紙ARM64锛?
- [ ] Web绠＄悊鐣岄潰
- [ ] 鑷姩澶囦唤绯荤粺
- [ ] 鎬ц兘鐩戞帶浠〃鏉?
- [ ] 鎻掍欢绯荤粺锛堝姩鎬佸姞杞芥ā缁勶級

---

**鏈€鍚庢洿鏂帮細** 2025-11-04
**褰撳墠鐗堟湰锛?* v1.0.35
