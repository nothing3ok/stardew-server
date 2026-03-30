# Puppy Stardew Server

涓€涓潰鍚戙€婃槦闇茶胺鐗╄銆嬪浜鸿仈鏈虹殑 Docker 鍖栨湇鍔″櫒椤圭洰锛屽甫鎸佷箙鍖栨暟鎹洰褰曘€佸唴缃?SMAPI 妯＄粍锛屼互鍙婂彲鐩存帴鍦ㄦ祻瑙堝櫒閲屾搷浣滅殑 Web 绠＄悊闈㈡澘銆?
[English](README.md)

## 椤圭洰绠€浠?
Puppy Stardew Server 鎶?Stardew Valley銆丼MAPI 鍜屼竴缁勯€傚悎鏈嶅姟鍣ㄥ満鏅殑妯＄粍鎵撳寘杩?Docker 宸ヤ綔娴侊紝閫傚悎閮ㄧ讲鍦ㄤ簯鏈嶅姟鍣ㄣ€佸鐢ㄤ富鏈烘垨 NAS 涓娿€?
褰撳墠椤圭洰宸茬粡鍖呭惈锛?
- 瀛樻。銆佹棩蹇椼€佸浠姐€侀潰鏉挎暟鎹€佽嚜瀹氫箟妯＄粍鐨勬寔涔呭寲
- Web 闈㈡澘绠＄悊鐘舵€併€佹棩蹇椼€侀厤缃€佸瓨妗ｃ€佸浠藉拰妯＄粍
- 瀛樻。涓婁紶銆佸浠姐€佷笅杞姐€佸垹闄ょ瓑甯哥敤鎿嶄綔
- 鑱旀満瀛樻。鐨?Host Migration 鍔熻兘
- 閫氳繃鍐呯疆妯＄粍鑷姩鍔犺浇瀛樻。
- 棣栨杩涙父鎴忔椂鍙€夌殑 VNC 杩滅▼妗岄潰

## 鍐呯疆缁勪欢

- Stardew Valley
- SMAPI
- Always On Server
- AutoHideHost
- ServerAutoLoad
- Skill Level Guard
- Web 闈㈡澘 `docker/web-panel`

## 榛樿绔彛

- `24642/udp`锛氭槦闇茶胺鑱旀満绔彛
- `5900/tcp`锛歏NC 杩滅▼妗岄潰
- `9090/tcp`锛歅rometheus 鎸囨爣
- `18642/tcp`锛歐eb 闈㈡澘

## 鎸佷箙鍖栫洰褰?
椤圭洰杩愯鏃舵暟鎹粯璁や繚瀛樺湪 `./data` 涓嬶細

- `data/saves`
- `data/game`
- `data/steam`
- `data/logs`
- `data/backups`
- `data/panel`
- `data/custom-mods`

## 閮ㄧ讲鏂瑰紡

### 鑷姩閮ㄧ讲

濡傛灉浣犲笇鏈涘湪涓€鍙板叏鏂扮殑鏈嶅姟鍣ㄤ笂鐩存帴涓€閿垵濮嬪寲锛屼紭鍏堜娇鐢ㄤ笅闈㈣繖涓や釜鍛戒护銆?
鑻辨枃寮曞鑴氭湰锛?
```bash
curl -fsSL https://raw.githubusercontent.com/nothing3ok/stardew-server/main/quick-start.sh | bash
```

涓枃寮曞鑴氭湰锛?
```bash
curl -fsSL https://raw.githubusercontent.com/nothing3ok/stardew-server/main/quick-start-zh.sh | bash
```

濡傛灉浣犲凡缁忓厛鎶婁粨搴撳厠闅嗗埌鏈湴锛屼篃鍙互鐩存帴鎵ц锛?
```bash
./quick-start.sh
# 鎴?./quick-start-zh.sh
```

鑴氭湰浼氳嚜鍔ㄥ畬鎴愯繖浜涗簨鎯咃細

- 妫€鏌?Docker 鍜?Docker Compose
- 鍒涘缓 `.env`
- 寮曞濉啓 Steam 璐﹀彿
- 鍒涘缓鏁版嵁鐩綍
- 淇鐩綍鏉冮檺
- 鍚姩鏈嶅姟
- 杈撳嚭 Steam Guard銆乂NC 鍜?Web 闈㈡澘鐨勪笅涓€姝ヨ鏄?
### 鎵嬪姩閮ㄧ讲

濡傛灉浣犲笇鏈涜嚜宸辨帉鎺ф瘡涓€姝ワ紝浣跨敤鎵嬪姩鏂瑰紡銆?
#### 1. 鍓嶇疆瑕佹眰

- 宸插畨瑁?Docker
- 宸插畨瑁?Docker Compose
- 涓€涓凡缁忚喘涔?Stardew Valley 鐨?Steam 璐﹀彿
- 鑷冲皯 2 GB 鍐呭瓨
- 鑷冲皯 2 GB 鍙敤纾佺洏绌洪棿

#### 2. 鍏嬮殕浠撳簱

```bash
git clone https://github.com/nothing3ok/stardew-server.git
cd stardew-server
```

#### 3. 鍒涘缓 `.env`

```bash
cp .env.example .env
```

鐒跺悗缂栬緫 `.env`锛岃嚦灏戝～鍐欒繖浜涘瓧娈碉細

```env
STEAM_USERNAME=your_steam_username
STEAM_PASSWORD=your_steam_password
ENABLE_VNC=true
VNC_PASSWORD=stardew1
```

#### 4. 鍒濆鍖栨暟鎹洰褰?
```bash
./init.sh
```

杩欎竴姝ヤ細鍒涘缓鎵€闇€鐩綍锛屽苟鎶婃潈闄愯缃负 `1000:1000`銆?
#### 5. 鍚姩鏈嶅姟

```bash
docker compose up -d
```

#### 6. 鏌ョ湅鍚姩鏃ュ織

```bash
docker logs -f nothing-stardew
```

濡傛灉鍚敤浜?Steam Guard锛?
```bash
docker attach nothing-stardew
```

杈撳叆楠岃瘉鐮佸悗绛夊緟鍑犵锛屽啀鎸?`Ctrl+P Ctrl+Q` 閫€鍑洪檮鐫€銆?
## 棣栨鍚姩鍚庣殑浣跨敤鏂瑰紡

瀹瑰櫒鍚姩鍚庯紝閫氬父鏈変袱绉嶇鐞嗘柟寮忋€?
### 鏂瑰紡 1锛歐eb 闈㈡澘

娴忚鍣ㄨ闂細

```text
http://浣犵殑鏈嶅姟鍣↖P:18642
```

绗竴娆¤闂細瑕佹眰浣犲垱寤虹鐞嗗憳瀵嗙爜銆?
褰撳墠 Web 闈㈡澘宸茬粡鏀寔锛?
- 浠〃鐩樺拰杩愯鐘舵€佹煡鐪?- 瀹炴椂鏃ュ織
- SMAPI 缁堢
- 瀛樻。鍒楄〃鍜岄粯璁ゅ瓨妗ｉ€夋嫨
- 瀛樻。涓婁紶
- 瀛樻。澶囦唤
- 澶囦唤涓嬭浇鍒版湰鍦?- 澶囦唤姘镐箙鍒犻櫎
- 瀛樻。鍒犻櫎
- 鑱旀満瀛樻。 Host Migration
- 閰嶇疆缂栬緫
- 妯＄粍绠＄悊

### 鏂瑰紡 2锛歏NC

鐢?VNC 瀹㈡埛绔繛鎺ワ細

```text
浣犵殑鏈嶅姟鍣↖P:5900
```

瀵嗙爜浣跨敤 `.env` 閲岀殑 `VNC_PASSWORD`銆?
VNC 閫傚悎杩欎簺鍦烘櫙锛?
- 鎵嬪姩鍒涘缓涓€涓柊鐨勮仈鏈哄啘鍦?- 鎵嬪姩鍦ㄦ父鎴忛噷鍔犺浇鏃у瓨妗?- 绗竴娆″紑鏈嶆椂鍋氬彲瑙嗗寲纭

瀹屾垚棣栨璁剧疆鍚庯紝鍚庣画閲嶅惎閫氬父鍙互渚濋潬鍐呯疆妯＄粍鑷姩鍔犺浇瀛樻。銆?
## 瀛樻。鍜屽浠借兘鍔?
褰撳墠椤圭洰鍦?Web 闈㈡澘閲屾敮鎸佽繖浜涘瓨妗ｇ浉鍏虫搷浣滐細

- 涓婁紶瀛樻。鍘嬬缉鍖呮垨瀛樻。鐩綍鍖?- 閫夋嫨榛樿鑷姩鍔犺浇鐨勫瓨妗?- 鍦ㄩ珮椋庨櫓鎿嶄綔鍓嶈嚜鍔ㄥ垱寤哄浠?- 鎶婂浠戒笅杞藉埌鏈湴鐢佃剳
- 姘镐箙鍒犻櫎澶囦唤
- 鍦ㄩ潰鏉垮唴鍒犻櫎瀛樻。
- 瀵硅仈鏈哄瓨妗ｆ墽琛?Host Migration

澶囦唤鏂囦欢榛樿淇濆瓨浣嶇疆锛?
```text
./data/backups
```

## 甯哥敤鍛戒护

鍚姩锛?
```bash
docker compose up -d
```

閲嶅惎锛?
```bash
docker compose restart
```

鍋滄锛?
```bash
docker compose down
```

鏌ョ湅鏃ュ織锛?
```bash
docker logs -f nothing-stardew
```

杩涘叆瀹瑰櫒锛?
```bash
docker exec -it nothing-stardew bash
```

## 鏁呴殰鎺掓煡

### 涓嬭浇娓告垙鏃舵姤 `Disk write failure`

閫氬父鏄?`data/` 鐩綍鏉冮檺涓嶅銆?
鍏堟墽琛岋細

```bash
./init.sh
```

鎴栬€呮墜鍔ㄤ慨澶嶏細

```bash
chown -R 1000:1000 data/
docker compose restart
```

### 鐜╁鏃犳硶鍔犲叆

- 妫€鏌?`24642/udp` 鏄惁鏀捐
- 纭瀛樻。宸茬粡鎴愬姛鍔犺浇
- 纭瀹㈡埛绔拰鏈嶅姟绔父鎴忕増鏈竴鑷?
### Steam Guard 闃诲棣栨鍚姩

闄勭潃鍒板鍣ㄥ悗杈撳叆楠岃瘉鐮侊細

```bash
docker attach nothing-stardew
```

閫€鍑烘椂浣跨敤 `Ctrl+P Ctrl+Q`锛屼笉瑕佺敤 `Ctrl+C`銆?
## 璇存槑

- 浣犲繀椤诲悎娉曟嫢鏈?Steam 鐗?Stardew Valley
- 鏈」鐩笉鏄洍鐗堝伐鍏?- VNC 鍗忚鍙敮鎸佹渶澶?8 浣嶅瘑鐮?- 淇敼 `.env` 鍚庨渶瑕侀噸鍚鍣ㄦ墠浼氱敓鏁?
## 璁稿彲璇?
MIT
