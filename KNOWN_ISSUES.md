# Known Issues / 宸茬煡闂

This document lists known limitations and issues with workarounds.

鏈枃妗ｅ垪鍑轰簡宸茬煡鐨勯檺鍒跺拰闂鍙婂叾瑙ｅ喅鏂规硶銆?

---

## Container Restart - Manual Save Reload Required
## 瀹瑰櫒閲嶅惎 - 闇€瑕佹墜鍔ㄩ噸鏂板姞杞藉瓨妗?

**Issue / 闂:**

When the container restarts, the save file is automatically loaded but the multiplayer server component is not fully initialized. Players cannot connect until the save is manually reloaded through VNC.

瀹瑰櫒閲嶅惎鍚庯紝瀛樻。鏂囦欢浼氳嚜鍔ㄥ姞杞斤紝浣嗚仈鏈烘湇鍔″櫒缁勪欢鏈畬鍏ㄥ垵濮嬪寲銆傜帺瀹舵棤娉曡繛鎺ワ紝闇€瑕侀€氳繃 VNC 鎵嬪姩閲嶆柊鍔犺浇瀛樻。銆?

**Why This Happens / 鍘熷洜:**

The Server Auto Load mod uses reflection to automatically load the save file on startup. However, in Stardew Valley 1.6+, the multiplayer networking layer (`Game1.server`) requires initialization through the game's Co-op menu flow, not just loading save data. The automatic load bypasses this initialization.

Server Auto Load 妯＄粍浣跨敤鍙嶅皠鍦ㄥ惎鍔ㄦ椂鑷姩鍔犺浇瀛樻。鏂囦欢銆備絾鏄湪鏄熼湶璋风墿璇?1.6+ 鐗堟湰涓紝鑱旀満缃戠粶灞傦紙`Game1.server`锛夐渶瑕侀€氳繃娓告垙鐨?Co-op 鑿滃崟娴佺▼鍒濆鍖栵紝鑰屼笉浠呬粎鏄姞杞藉瓨妗ｆ暟鎹€傝嚜鍔ㄥ姞杞界粫杩囦簡杩欎釜鍒濆鍖栬繃绋嬨€?

**Workaround / 瑙ｅ喅鏂规硶:**

After container restart, follow these steps to restore multiplayer functionality:

瀹瑰櫒閲嶅惎鍚庯紝鎸変互涓嬫楠ゆ仮澶嶈仈鏈哄姛鑳斤細

1. Connect to the server via VNC (port 5900)
   閫氳繃 VNC 杩炴帴鍒版湇鍔″櫒锛堢鍙?5900锛?

2. Press ESC to return to the title screen
   鎸?ESC 杩斿洖鏍囬鐣岄潰

3. Click "CO-OP" 鈫?Select your save 鈫?Click "Load"
   鐐瑰嚮 "CO-OP" 鈫?閫夋嫨浣犵殑瀛樻。 鈫?鐐瑰嚮 "鍔犺浇"

4. The multiplayer server will now be fully initialized and players can connect
   鑱旀満鏈嶅姟鍣ㄧ幇鍦ㄥ凡瀹屽叏鍒濆鍖栵紝鐜╁鍙互杩炴帴

**Time Required / 鎵€闇€鏃堕棿:** ~30 seconds / 绾?0绉?

**Impact / 褰卞搷:**

- Does not affect normal operation (only after restarts)
  涓嶅奖鍝嶆甯歌繍琛岋紙浠呭湪閲嶅惎鍚庯級

- Does not cause data loss - all progress is saved
  涓嶄細瀵艰嚧鏁版嵁涓㈠け - 鎵€鏈夎繘搴﹂兘宸蹭繚瀛?

- Container health check will still pass (game is running)
  瀹瑰櫒鍋ュ悍妫€鏌ヤ粛浼氶€氳繃锛堟父鎴忔鍦ㄨ繍琛岋級

**Status / 鐘舵€?**

This is a known limitation. A permanent fix would require modifying the Server Auto Load mod to properly initialize the multiplayer server component, which involves complex reflection and may break with future game updates.

杩欐槸宸茬煡鐨勯檺鍒躲€傛案涔呬慨澶嶉渶瑕佷慨鏀?Server Auto Load 妯＄粍浠ユ纭垵濮嬪寲鑱旀満鏈嶅姟鍣ㄧ粍浠讹紝杩欐秹鍙婂鏉傜殑鍙嶅皠鎿嶄綔锛屽彲鑳藉湪鏈潵鐨勬父鎴忔洿鏂颁腑澶辨晥銆?

For most users, the current workaround is acceptable since container restarts are infrequent (typically only for updates or maintenance).

瀵逛簬澶у鏁扮敤鎴锋潵璇达紝褰撳墠鐨勮В鍐虫柟娉曟槸鍙互鎺ュ彈鐨勶紝鍥犱负瀹瑰櫒閲嶅惎骞朵笉棰戠箒锛堥€氬父鍙敤浜庢洿鏂版垨缁存姢锛夈€?

---

## Audio Warnings in Logs
## 鏃ュ織涓殑闊抽璀﹀憡

**Issue / 闂:**

You may see these warnings in the logs:
鏃ュ織涓彲鑳戒細鐪嬪埌杩欎簺璀﹀憡锛?

```
OpenAL device could not be initialized
Steam achievements won't work because Steam isn't loaded
```

**Why This Happens / 鍘熷洜:**

The server runs in a headless environment without audio hardware or Steam client.
鏈嶅姟鍣ㄥ湪鏃犻煶棰戠‖浠舵垨 Steam 瀹㈡埛绔殑 headless 鐜涓繍琛屻€?

**Impact / 褰卞搷:**

None - these are harmless warnings and do not affect server functionality.
鏃犲奖鍝?- 杩欎簺鏄棤瀹崇殑璀﹀憡锛屼笉褰卞搷鏈嶅姟鍣ㄥ姛鑳姐€?

**Workaround / 瑙ｅ喅鏂规硶:**

No action needed. These warnings can be safely ignored.
鏃犻渶鎿嶄綔銆傚彲浠ュ畨鍏ㄥ湴蹇界暐杩欎簺璀﹀憡銆?

---

## VNC Connection Required for First Setup
## 棣栨璁剧疆闇€瑕?VNC 杩炴帴

**Issue / 闂:**

The first time you start the server, you must use VNC to create or load a save file.
棣栨鍚姩鏈嶅姟鍣ㄦ椂锛屽繀椤讳娇鐢?VNC 鍒涘缓鎴栧姞杞藉瓨妗ｆ枃浠躲€?

**Why This Happens / 鍘熷洜:**

Stardew Valley's multiplayer server requires an active save file. The game must be launched and a Co-op save created through the in-game interface.
鏄熼湶璋风墿璇殑鑱旀満鏈嶅姟鍣ㄩ渶瑕佷竴涓椿鍔ㄧ殑瀛樻。鏂囦欢銆傚繀椤诲惎鍔ㄦ父鎴忓苟閫氳繃娓告垙鍐呯晫闈㈠垱寤?Co-op 瀛樻。銆?

**Impact / 褰卞搷:**

One-time setup only. After the initial save is created, it will auto-load on subsequent starts (though multiplayer may require manual reload after restarts - see issue above).
浠呴渶涓€娆¤缃€傚垱寤哄垵濮嬪瓨妗ｅ悗锛屽悗缁惎鍔ㄦ椂浼氳嚜鍔ㄥ姞杞斤紙灏界閲嶅惎鍚庤仈鏈哄彲鑳介渶瑕佹墜鍔ㄩ噸鏂板姞杞?- 瑙佷笂杩伴棶棰橈級銆?

**Workaround / 瑙ｅ喅鏂规硶:**

Follow the setup instructions in the README:
鎸夌収 README 涓殑璁剧疆璇存槑锛?

1. Connect via VNC (port 5900, password from .env file)
   閫氳繃 VNC 杩炴帴锛堢鍙?5900锛屽瘑鐮佹潵鑷?.env 鏂囦欢锛?

2. Click "CO-OP" 鈫?"Start new co-op farm" or "Load" existing save
   鐐瑰嚮 "CO-OP" 鈫?"寮€濮嬫柊鐨勮仈鏈哄啘鍦? 鎴?"鍔犺浇" 鐜版湁瀛樻。

3. After setup, you can disable VNC if desired to save ~50MB RAM
   璁剧疆瀹屾垚鍚庯紝濡傞渶鑺傜渷绾?50MB 鍐呭瓨锛屽彲绂佺敤 VNC

---

## Reporting New Issues / 鎶ュ憡鏂伴棶棰?

If you encounter an issue not listed here, please report it:
濡傛灉閬囧埌姝ゅ鏈垪鍑虹殑闂锛岃鎶ュ憡锛?

- GitHub Issues: https://github.com/nothing3ok/stardew-server/issues
- Docker Hub: https://hub.docker.com/r/truemanlive/nothing-stardew-server

Please include:
璇峰寘鍚細

- Container logs: `docker logs nothing-stardew`
- Game version from logs
- Steps to reproduce

---

**Last Updated:** 2025-10-29
**Version:** v1.0.23
