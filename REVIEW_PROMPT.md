# GPU 娓叉煋鏀寔淇敼瀹℃煡鎻愮ず璇?(Issue #19)

## 瀹℃煡鑳屾櫙

鎴戜滑涓?Stardew Valley 鏈嶅姟鍣ㄦ坊鍔犱簡 GPU 纭欢鍔犻€熸敮鎸侊紝浠ラ檷浣庝簯鏈嶅姟鍣ㄤ笂鐨?CPU 鍗犵敤銆傚綋鍓嶄娇鐢?Xvfb锛堣蒋浠舵覆鏌擄級瀵艰嚧 CPU 鍗犵敤鏋侀珮锛岀幇鍦ㄦ敮鎸侀€氳繃 Xorg + GPU 杩涜纭欢鍔犻€熸覆鏌撱€?

## 淇敼鐩爣

1. 鏀寔 GPU 纭欢鍔犻€燂紙閫氳繃 Xorg + modesetting 椹卞姩锛?
2. 淇濇寔鍚戝悗鍏煎锛堣嚜鍔ㄥ洖閫€鍒?Xvfb 杞欢娓叉煋锛?
3. 鐢ㄦ埛鍙€氳繃 `USE_GPU=true` 鐜鍙橀噺鍚敤
4. 鏀寔鑷畾涔夊垎杈ㄧ巼锛圧ESOLUTION_WIDTH/HEIGHT/REFRESH_RATE锛?

## 鏍稿績閫昏緫娴佺▼

```
鍚姩娴佺▼锛?
1. Root 闃舵锛?
   - 濡傛灉 USE_GPU=true 涓?/dev/dri 鍙敤 鈫?鍚姩 Xorg :99
   - 鍚﹀垯 鈫?璺宠繃锛岀瓑寰?steam 闃舵

2. Steam 闃舵锛?
   - 妫€娴?Xorg 杩涚▼鏄惁杩愯
   - 濡傛灉杩愯 鈫?浣跨敤 Xorg锛圙PU 鍔犻€燂級
   - 濡傛灉鏈繍琛?鈫?鍚姩 Xvfb锛堣蒋浠舵覆鏌撳洖閫€锛?

3. VNC 杩炴帴鍒板綋鍓?DISPLAY锛?99锛?
```

## 闇€瑕佸鏌ョ殑鍏抽敭鐐?

### 1. Dockerfile 瀹℃煡瑕佺偣

**鏂囦欢璺緞**: `docker/Dockerfile`

妫€鏌ラ」锛?
- [ ] 鐗堟湰鍙锋槸鍚︽纭洿鏂颁负 1.0.64
- [ ] GPU 鐩稿叧渚濊禆鍖呮槸鍚﹀畬鏁达細
  - libgl1-mesa-dri, libgl1-mesa-glx, mesa-utils, libegl1-mesa
  - xserver-xorg-core, xserver-xorg-video-modesetting
  - x11-xserver-utils, x11-apps
- [ ] steam 鐢ㄦ埛鏄惁鍔犲叆 video 缁勶細`usermod -aG video steam`
- [ ] 20-modesetting.conf 閰嶇疆鏄惁姝ｇ‘鍒涘缓锛坢odesetting 椹卞姩 + glamor + DRI3锛?
- [ ] set-resolution.sh 鏄惁姝ｇ‘ COPY
- [ ] 10-monitor.conf 鏄惁姝ｇ‘ COPY 鍒?/etc/X11/xorg.conf.d/

**娼滃湪闂**锛?
- 渚濊禆鍖呮槸鍚︿細瀵艰嚧闀滃儚浣撶Н杩囧ぇ锛?
- 20-modesetting.conf 鐨?EOF heredoc 璇硶鏄惁姝ｇ‘锛?

---

### 2. entrypoint.sh 瀹℃煡瑕佺偣

**鏂囦欢璺緞**: `docker/scripts/entrypoint.sh`

妫€鏌ラ」锛?
- [ ] 鐗堟湰鍙锋槸鍚︽洿鏂颁负 1.0.64
- [ ] 鍒嗚鲸鐜囩幆澧冨彉閲忛粯璁ゅ€兼槸鍚﹀悎鐞嗭紙1280x720@60Hz锛?
- [ ] `start_gpu_xorg()` 鍑芥暟閫昏緫锛?
  - [ ] USE_GPU != true 鏃舵槸鍚︽纭繑鍥炲苟璺宠繃
  - [ ] /dev/dri 妫€娴嬮€昏緫鏄惁姝ｇ‘
  - [ ] Xorg 鍚姩鍛戒护鏄惁姝ｇ‘锛?noreset +extension GLX +extension RANDR :99锛?
  - [ ] set-resolution.sh 璋冪敤鏄惁姝ｇ‘浼犻€掑弬鏁?
  - [ ] glxinfo 妫€娴?OpenGL renderer 鏄惁姝ｇ‘
- [ ] Root 闃舵鏄惁姝ｇ‘璋冪敤 `start_gpu_xorg "root"`
- [ ] `exec runuser` 鏄惁姝ｇ‘浼犻€?DISPLAY 鐜鍙橀噺
- [ ] Steam 闃舵铏氭嫙鏄剧ず閫昏緫锛?
  - [ ] 鏄惁姝ｇ‘妫€娴?Xorg 杩涚▼锛坧grep -x Xorg锛?
  - [ ] 鍥為€€鍒?Xvfb 鐨勯€昏緫鏄惁姝ｇ‘
  - [ ] Xvfb 鍚姩鍛戒护鏄惁浣跨敤鍔ㄦ€佸垎杈ㄧ巼鍙橀噺
- [ ] VNC 鍚姩鏄惁浣跨敤鍔ㄦ€?DISPLAY 鍙橀噺锛堜笉鍐嶇‖缂栫爜 :99锛?

**娼滃湪闂**锛?
- Xorg 鍚姩澶辫触鏃舵槸鍚︿細瀵艰嚧瀹瑰櫒閫€鍑猴紵锛堝簲璇ュ洖閫€鍒?Xvfb锛?
- DISPLAY 鐜鍙橀噺浼犻€掓槸鍚︿細鍦?runuser 鍒囨崲鐢ㄦ埛鏃朵涪澶憋紵
- set-resolution.sh 澶辫触鏄惁浼氶樆濉炲惎鍔紵锛堝簲璇ュ彧鏄鍛婏級

---

### 3. docker-compose.yml 瀹℃煡瑕佺偣

**鏂囦欢璺緞**: `docker-compose.yml`

妫€鏌ラ」锛?
- [ ] 闀滃儚鐗堟湰鏄惁浠嶄负 v1.0.61锛堥渶瑕佹墜鍔ㄦ洿鏂颁负 v1.0.64锛?
- [ ] 鏂板鐜鍙橀噺鏄惁姝ｇ‘锛?
  - [ ] USE_GPU=${USE_GPU:-false}
  - [ ] RESOLUTION_WIDTH=${RESOLUTION_WIDTH:-1280}
  - [ ] RESOLUTION_HEIGHT=${RESOLUTION_HEIGHT:-720}
  - [ ] REFRESH_RATE=${REFRESH_RATE:-60}
- [ ] /dev/dri 璁惧鏄犲皠娉ㄩ噴鏄惁娓呮櫚
- [ ] 娉ㄩ噴鏄惁璇存槑闇€瑕佸彇娑堟敞閲婃墠鑳藉惎鐢?GPU

**娼滃湪闂**锛?
- 闀滃儚鐗堟湰鍙锋槸鍚﹂渶瑕佹洿鏂帮紵锛堝綋鍓嶄粛涓?v1.0.61锛?

---

### 4. .env.example 瀹℃煡瑕佺偣

**鏂囦欢璺緞**: `.env.example`

妫€鏌ラ」锛?
- [ ] USE_GPU 璇存槑鏄惁娓呮櫚锛堥粯璁?false锛岄渶瑕?/dev/dri锛?
- [ ] 鍒嗚鲸鐜囪缃鏄庢槸鍚︽竻鏅?
- [ ] 鏄惁璇存槑浜嗗惎鐢?GPU 鐨勮姹傦紙瀹夸富鏈?/dev/dri + docker-compose.yml 鏄犲皠锛?

**娼滃湪闂**锛?
- 鐢ㄦ埛鏄惁鑳芥竻妤氱悊瑙ｅ浣曞惎鐢?GPU锛?

---

### 5. 宸插瓨鍦ㄦ枃浠舵鏌?

**鏂囦欢璺緞**:
- `docker/scripts/set-resolution.sh`
- `docker/config/10-monitor.conf`

妫€鏌ラ」锛?
- [ ] set-resolution.sh 鏄惁鏈夋墽琛屾潈闄?
- [ ] set-resolution.sh 閫昏緫鏄惁姝ｇ‘锛坸randr 璁剧疆鍒嗚鲸鐜?+ cvt 鍥為€€锛?
- [ ] 10-monitor.conf 閰嶇疆鏄惁姝ｇ‘锛?280x720_60.00 + modesetting + glamor锛?

---

## 鍏煎鎬ф鏌?

### 鍚戝悗鍏煎鎬?
- [ ] USE_GPU 鏈缃垨涓?false 鏃讹紝鏄惁姝ｅ父浣跨敤 Xvfb锛?
- [ ] /dev/dri 涓嶅瓨鍦ㄦ椂锛屾槸鍚︽甯稿洖閫€鍒?Xvfb锛?
- [ ] 鐜版湁鐢ㄦ埛鍗囩骇鍚庢槸鍚︽棤闇€淇敼閰嶇疆鍗冲彲姝ｅ父杩愯锛?

### 閿欒澶勭悊
- [ ] Xorg 鍚姩澶辫触鏃舵槸鍚︽湁鏄庣‘鏃ュ織锛?
- [ ] set-resolution.sh 澶辫触鏃舵槸鍚﹀彧鏄鍛婅€屼笉闃诲锛?
- [ ] /dev/dri 鏉冮檺涓嶈冻鏃舵槸鍚︽湁娓呮櫚鎻愮ず锛?

---

## 娴嬭瘯鍦烘櫙

### 鍦烘櫙 1: 榛樿琛屼负锛堜笉鍚敤 GPU锛?
```bash
# .env 涓笉璁剧疆 USE_GPU 鎴?USE_GPU=false
# docker-compose.yml 涓嶆槧灏?/dev/dri
docker compose up -d
```
**棰勬湡**锛氫娇鐢?Xvfb 杞欢娓叉煋锛屼笌涔嬪墠鐗堟湰琛屼负涓€鑷?

### 鍦烘櫙 2: 鍚敤 GPU锛堟湁 /dev/dri锛?
```bash
# .env 涓缃?USE_GPU=true
# docker-compose.yml 鍙栨秷娉ㄩ噴 devices: - /dev/dri:/dev/dri
docker compose up -d
```
**棰勬湡**锛氫娇鐢?Xorg + GPU 纭欢鍔犻€燂紝鏃ュ織鏄剧ず OpenGL renderer

### 鍦烘櫙 3: 鍚敤 GPU锛堟棤 /dev/dri锛?
```bash
# .env 涓缃?USE_GPU=true
# docker-compose.yml 涓嶆槧灏?/dev/dri
docker compose up -d
```
**棰勬湡**锛氭娴嬪埌 /dev/dri 涓嶅彲鐢紝鍥為€€鍒?Xvfb锛屾棩蹇楁湁璀﹀憡

### 鍦烘櫙 4: 鑷畾涔夊垎杈ㄧ巼
```bash
# .env 涓缃?
RESOLUTION_WIDTH=1920
RESOLUTION_HEIGHT=1080
REFRESH_RATE=60
docker compose up -d
```
**棰勬湡**锛氳櫄鎷熸樉绀轰娇鐢?1920x1080@60Hz

---

## 瀹℃煡杈撳嚭鏍煎紡

璇锋寜浠ヤ笅鏍煎紡杈撳嚭瀹℃煡缁撴灉锛?

```
## 瀹℃煡缁撴灉

### 鉁?閫氳繃鐨勬鏌ラ」
- [鍒楀嚭鎵€鏈夐€氳繃鐨勬鏌ラ」]

### 鈿狅笍 闇€瑕佹敞鎰忕殑闂
- [鍒楀嚭娼滃湪闂鎴栨敼杩涘缓璁甝

### 鉂?鍙戠幇鐨勯敊璇?
- [鍒楀嚭鏄庣‘鐨勯敊璇紝闇€瑕佷慨澶峕

### 馃摑 寤鸿
- [鍏朵粬寤鸿鎴栦紭鍖栨柟鍚慮

### 鎬讳綋璇勪环
[PASS / NEEDS_FIX / NEEDS_IMPROVEMENT]
```

---

## 鍙傝€冨疄鐜?

鍙傝€冨垎鏀細`dezhishen/nothing-stardew-server` 鐨?`feat/xorg` 鍒嗘敮
- Dockerfile: https://github.com/dezhishen/nothing-stardew-server/blob/feat/xorg/docker/Dockerfile
- entrypoint.sh: https://github.com/dezhishen/nothing-stardew-server/blob/feat/xorg/docker/scripts/entrypoint.sh
