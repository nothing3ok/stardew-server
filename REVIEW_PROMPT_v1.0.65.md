# Code Review Request - v1.0.65 (Issue #17 Fix)

## 瀹℃煡鐩爣

璇峰鏌?**v1.0.65** 鐗堟湰鐨勪唬鐮佷慨鏀癸紝閲嶇偣鍏虫敞 **Issue #17锛堝噷鏅?鐐规檿鍊掑鑷翠富鏈哄崱浣忥級** 鐨勪慨澶嶆柟妗堛€?

## 淇敼鍐呭

### 1. 鏂板鏂囦欢
- `docker/scripts/auto-handle-passout.sh` - 鐩戞帶骞惰嚜鍔ㄥ鐞嗗噷鏅?鐐规檿鍊掍簨浠?

### 2. 淇敼鏂囦欢
- `docker/Dockerfile` - 娣诲姞 auto-handle-passout.sh 鐨?COPY锛岀増鏈彿鏇存柊鍒?1.0.65
- `docker/scripts/entrypoint.sh` - 鍚姩 auto-handle-passout.sh 鍚庡彴鑴氭湰锛岀増鏈彿鏇存柊鍒?1.0.65
- `docker-compose.yml` - 闀滃儚鐗堟湰鏇存柊鍒?v1.0.65

## 瀹℃煡閲嶇偣

### 鉁?鍔熻兘姝ｇ‘鎬?
1. **鏃ュ織鐩戞帶閫昏緫**
   - 妫€娴嬪叧閿瓧鏄惁鍑嗙‘锛歚passed out|exhausted|collapsed|fell asleep`
   - tail -50 琛屾暟鏄惁瓒冲鎹曡幏浜嬩欢
   - grep 姝ｅ垯琛ㄨ揪寮忔槸鍚︽纭?

2. **鑷姩澶勭悊娴佺▼**
   - F9 鈫?鏂瑰悜閿Щ鍔?鈫?Enter 鐨勯『搴忔槸鍚﹀悎鐞?
   - sleep 寤惰繜鏃堕棿鏄惁鍚堥€傦紙1s, 0.3s, 0.5s锛?
   - 鏄惁浼氬共鎵版甯告父鎴忔祦绋?

3. **闃查噸澶嶆満鍒?*
   - 30 绉掑喎鍗存椂闂存槸鍚﹁冻澶?
   - LAST_HANDLE_TIME 閫昏緫鏄惁姝ｇ‘

### 鈿狅笍 娼滃湪闂
1. **绔炴€佹潯浠?*
   - 澶氫釜鍚庡彴鑴氭湰鍚屾椂鎸?F9 鏄惁浼氬啿绐侊紵
   - xdotool 骞跺彂璋冪敤鏄惁瀹夊叏锛?

2. **璇Е鍙戦闄?*
   - 鍏抽敭瀛楁娴嬫槸鍚︿細璇垽鍏朵粬浜嬩欢锛?
   - 鏄惁闇€瑕佹洿绮剧‘鐨勬椂闂村垽鏂紙2AM = 2600锛夛紵

3. **璧勬簮鍗犵敤**
   - 姣?5 绉?tail + grep 鏄惁浼氬奖鍝嶆€ц兘锛?
   - 鏄惁闇€瑕佷紭鍖栦负 inotify 鐩戞帶锛?

4. **閿欒澶勭悊**
   - xdotool 涓嶅瓨鍦ㄦ椂鐨勫鐞嗘槸鍚﹀厖鍒嗭紵
   - SMAPI 鏃ュ織鏂囦欢涓嶅瓨鍦ㄦ椂鐨勫鐞嗭紵

### 馃攳 浠ｇ爜璐ㄩ噺
1. **鑴氭湰鍋ュ．鎬?*
   - 鏄惁闇€瑕佹坊鍔犳洿澶氶敊璇鐞嗭紵
   - 鏃ュ織杈撳嚭鏄惁娓呮櫚锛?

2. **涓庡叾浠栬剼鏈殑鍗忓悓**
   - 涓?auto-enable-server.sh 鐨?F9 鏄惁鍐茬獊锛?
   - 涓?auto-handle-readycheck.sh 鐨?Enter 鏄惁鍐茬獊锛?
   - 涓?auto-reconnect-server.sh 鐨?F9 鏄惁鍐茬獊锛?

3. **閰嶇疆鐏垫椿鎬?*
   - 鏄惁闇€瑕佺幆澧冨彉閲忔帶鍒跺惎鐢?绂佺敤锛?
   - CHECK_INTERVAL 鏄惁闇€瑕佸彲閰嶇疆锛?

## 瀹℃煡杈撳嚭鏍煎紡

璇锋寜浠ヤ笅鏍煎紡杈撳嚭瀹℃煡缁撴灉锛?

```
### 鉁?閫氳繃椤?
- [椤圭洰鍚嶇О]: 璇存槑

### 鈿狅笍 闇€瑕佹敞鎰?
- [椤圭洰鍚嶇О]: 闂鎻忚堪 + 寤鸿

### 鉂?蹇呴』淇
- [椤圭洰鍚嶇О]: 涓ラ噸闂 + 淇鏂规

### 馃挕 浼樺寲寤鸿
- [椤圭洰鍚嶇О]: 鏀硅繘寤鸿
```

## 鐩稿叧鏂囦欢璺緞

```
/root/nothing-stardew-server/docker/scripts/auto-handle-passout.sh
/root/nothing-stardew-server/docker/Dockerfile
/root/nothing-stardew-server/docker/scripts/entrypoint.sh
/root/nothing-stardew-server/docker-compose.yml
```

## 鍙傝€冧俊鎭?

- **Issue #17**: https://github.com/nothing3ok/stardew-server/issues/17
- **鐢ㄦ埛鍙嶉**: 鍑屾櫒2鐐规椂锛屽姞鍏ョ殑鐜╁浼氳嚜鍔ㄤ紤鎭紝浣嗕富鏈轰笉浼氾紝瀵艰嚧娓告垙鍗′綇
- **瑙ｅ喅鏂规**: 鎸?F9 + 绉诲姩瑙掕壊鍙互瑙﹀彂涓绘満浼戞伅
