# Mac mini로 13F 대시보드 배포하기

이 대시보드는 정적 HTML 파일 하나라서 서버 구성이 가볍습니다.

## 1. 맥미니에서 로컬 실행

가격 그래프 자동 업데이트를 쓰려면 한 번만 설치합니다.

```bash
cd /Users/bora/Documents/Codex/2026-06-08/role-sec-13f-context-13f-13f/outputs
./install_yfinance.sh
```

터미널에서 아래를 실행합니다.

```bash
cd /Users/bora/Documents/Codex/2026-06-08/role-sec-13f-context-13f-13f/outputs
PORT=8080 ./serve_dashboard.sh
```

맥미니에서 열기:

```text
http://localhost:8080/13f_dashboard.html
```

같은 집/사무실 와이파이의 다른 기기에서 열기:

```text
http://맥미니-로컬-IP:8080/13f_dashboard.html
```

로컬 IP 확인:

```bash
ipconfig getifaddr en0
```

## 2. 외부 사람에게 공개하는 추천 방식

### 추천: Cloudflare Tunnel

공유기 포트포워딩 없이 외부 공개가 가능합니다. 맥미니의 실제 IP를 숨길 수 있어 가장 무난합니다.

개념:

```text
방문자 → Cloudflare 주소 → Cloudflare Tunnel → 맥미니:8080 → 13F 대시보드
```

흐름:

1. 도메인을 Cloudflare에 연결합니다.
2. 맥미니에 `cloudflared`를 설치합니다.
3. `http://localhost:8080`을 Cloudflare Tunnel에 연결합니다.
4. 예: `https://13f.yourdomain.com/13f_dashboard.html`로 공유합니다.

장점:

- 공유기 설정이 거의 필요 없습니다.
- HTTPS가 자동으로 붙습니다.
- 집 IP를 직접 노출하지 않습니다.

주의:

- 대시보드가 공개되면 누구나 볼 수 있으므로 개인 메모나 계좌 정보는 넣지 마세요.
- 자동 업데이트 스레드 요약을 수동으로 대시보드에 반영하는 구조라면, 파일 갱신 후 서버는 그대로 두면 됩니다.

## 3. 대안: 공유기 포트포워딩 + DDNS

가능은 하지만 보안 부담이 큽니다.

개념:

```text
방문자 → DDNS 주소 → 공유기 80/443 또는 8080 포트 → 맥미니
```

필요한 것:

- 맥미니 고정 로컬 IP
- 공유기 포트포워딩
- DDNS 또는 고정 IP
- 가능하면 HTTPS 리버스 프록시

주의:

- 맥미니가 인터넷에 직접 노출됩니다.
- 방화벽, macOS 업데이트, 접근 로그 확인이 필요합니다.
- 개인용 공개라면 Cloudflare Tunnel이 보통 더 낫습니다.

## 4. 운영 체크리스트

- 맥미니 절전 해제: 시스템 설정에서 잠자기 방지
- 방화벽 확인: 8080 또는 터널 프로세스 허용
- 대시보드 파일 위치 유지: `outputs/13f_dashboard.html`
- 가격 데이터 위치 유지: `outputs/prices.json`
- 가격 자동 업데이트: `serve_dashboard.sh` 실행 중 `yfinance`가 설치되어 있으면 1시간마다 갱신
- 민감정보 금지: 계좌, 보유 수량, 개인 매수가 입력 금지
- 업데이트 주기: 13F 시즌에는 분기 1회, 시장 점검은 주간/월간

## 5. 권장 운영 구조

개인/지인 공유 목적이면:

```text
맥미니 + serve_dashboard.sh + Cloudflare Tunnel
```

투자 리서치 페이지로 조금 더 제대로 운영하려면:

```text
맥미니 + Nginx/Caddy + Cloudflare Tunnel + 별도 data.json
```

현재 버전은 단일 HTML이라 가장 단순한 구조입니다.
