# HV Hub — Anh cần chuẩn bị và chốt gì trước khi code

> Đi kèm [GIAI_PHAP.md](GIAI_PHAP.md) v0.2. Tick từng mục; mục nào để trống em dùng **đề xuất mặc định**.
> **Không gửi secret qua chat hay commit lên git.** Secret Amazon/Pancake nhập trên miniapp (lưu mã hoá); secret Cloudflare đặt bằng `npx wrangler secret put`.

## A. Amazon (yêu cầu #1, #2, #5, #10)

| # | Thông tin | Lấy ở đâu | Ghi chú |
|---|---|---|---|
| A1 | `client_id`, `client_secret` của app SP-API | Seller Central → Develop Apps (đang có trong `Amazon_Configs.ClientId/ClientSecret` của hệ thống cũ) | Nhập trên miniapp |
| A2 | Ngày hết hạn client secret | Developer Central → app → LWA credentials | Để cảnh báo xoay vòng |
| A3 | Danh sách shop: tên, Seller ID (Merchant Token), region (`na`/`eu`/`fe`), marketplace | Seller Central → Account info | VD US = `ATVPDKIKX0DER` |
| A4 | `refresh_token` từng shop | `Amazon_Configs.RefreshToken` hiện tại, hoặc Authorize app lại | Nhập trên miniapp |
| A5 | Role của app | Developer profile | Bắt buộc: **Inventory and Order Tracking**. Thêm theo dữ liệu cần sync: **Product Listing** (listing), **Amazon Fulfillment** (tồn FBA), **Finance and Accounting** (tài chính), **Selling Partner Insights** / Brand Analytics (nếu cần), **Direct-to-Consumer Shipping** (PII, chỉ khi cần tên/địa chỉ khách thật). Thêm role mới phải **authorize lại** để có refresh token mới. |
| A6 | (P5) Tài khoản AWS | — | Chỉ cần nếu làm realtime `ORDER_CHANGE` qua EventBridge |

## B. Pancake POS (yêu cầu #3, #11)

| # | Thông tin | Ghi chú |
|---|---|---|
| B1 | `SHOP_ID` + `api_key` của từng shop Pancake nhận đơn Amazon | Pancake → Cấu hình → Cấu hình ứng dụng → API KEY. Có thể dùng chung key đang nhập ở ops nếu cùng shop |
| B2 | **1 shop Pancake thử** (hoặc cho phép tạo đơn thử rồi huỷ trên shop thật) | Bắt buộc để kiểm trường tạo đơn trước khi đẩy thật |
| B3 | Shop/marketplace Amazon nào đổ về shop Pancake nào | VD: Amazon US + CA → Pancake "HV US" |
| B4 | Kho nhận đơn FBA và FBM (`warehouse_id`) | Hoặc em lấy danh sách qua API, anh chọn trên miniapp |
| B5 | Nguồn đơn: dùng nguồn có sẵn hay tạo nguồn "Amazon" riêng; thẻ gắn kèm | Đề xuất: nguồn "Amazon", thẻ `AMZ-<marketplace>` |
| B6 | Quy tắc mã: SKU Amazon có trùng mã mẫu mã / barcode trên Pancake không? | Quyết định tỉ lệ tự khớp |
| B7 | Danh sách combo/bundle (1 SKU Amazon = nhiều sản phẩm Pancake) nếu có | Có thể import CSV sau |
| B8 | Tiền tệ shop Pancake (USD/VND) và nguồn tỷ giá nếu quy VND | |

## C. Cloudflare (yêu cầu #4) — anh tạo, đặt đúng tên hv-hub

- [ ] Gói **Workers Paid** (Queues, CPU dài, nhiều cron) — tài khoản đang chạy ops là đủ
- [ ] D1 `hv-hub` (+ `hv-hub-staging`), vùng APAC như ops → gửi em `database_id`
- [ ] R2 bucket `hv-hub-raw`
- [ ] Queues `hv-hub-sync`, `hv-hub-pancake-push`, `hv-hub-dlq`
- [ ] Domain `hub.hvholdings.vn` (+ `hub-staging.hvholdings.vn`) — Worker tự tạo DNS khi deploy với `custom_domain`
- [ ] Worker secrets: `DATA_KEY` (32 byte base64, **khác** khoá của ops), `SESSION_SECRET` (≥ 32 ký tự), `ADMIN_USER`, `ADMIN_PASSWORD`, `LARK_WEBHOOK_URL` + `LARK_SECRET` (nếu dùng bot riêng)
- [ ] API Token Cloudflare (Workers Scripts, D1, R2, Queues: Edit) + Account ID → đặt vào GitHub Secrets `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` cho CI deploy
- [ ] (Tuỳ chọn) Cloudflare Access trước `hub.hvholdings.vn`
- [ ] (Sau này) Hyperdrive + PostgreSQL khi chuyển DB

## D. GitHub (yêu cầu #12)

- [ ] Tạo repo **private trống** `dungnt91/hv-hub` (không tick README/.gitignore). Môi trường của em không được phép tự tạo repo mới trên tài khoản anh, nên anh tạo giúp — xong báo em, em gắn repo vào phiên làm việc và đẩy code.
- [ ] Bật Claude GitHub App cho repo `hv-hub` (nếu chưa chọn "All repositories")
- [ ] Thêm 2 secret Cloudflare ở mục C

## E. Câu hỏi cần chốt

| # | Câu hỏi | Đề xuất mặc định |
|---|---|---|
| Q1 | Bao nhiêu shop / marketplace? Khoảng bao nhiêu đơn/ngày? Backfill từ ngày nào? | Backfill từ 01/01/2025 |
| Q2 | Ngoài đơn hàng, cần những dữ liệu nào và ưu tiên ra sao: listing, tồn FBA, tài chính/phí, hoàn hàng, khác? | Đơn + listing (P1); tồn FBA, tài chính, hoàn hàng (P4) |
| Q3 | App đã có role PII chưa? Có cần tên/địa chỉ khách thật trên Pancake không? | Không; giữ che PII như hiện tại |
| Q4 | Đơn ở trạng thái nào thì đẩy lên Pancake? | `UNSHIPPED`/`PARTIALLY_SHIPPED`/`SHIPPED`; không đẩy `PENDING`; đơn đã đẩy mà bị huỷ thì cập nhật |
| Q5 | Địa chỉ trên Pancake (Amazon là địa chỉ nước ngoài, Pancake cần mã tỉnh/huyện/xã VN)? | Địa chỉ cố định (kho/văn phòng) + tên "Amazon Customer" + SĐT giả theo mẫu hiện tại |
| Q6 | Ánh xạ trạng thái Amazon → Pancake; Pancake trừ tồn ở trạng thái nào; FBA có trừ tồn trên Pancake không? | Cần anh + bên kho quyết |
| Q7 | Đơn huỷ sau khi Pancake đã xử lý (đóng/gửi)? | Chỉ huỷ khi Pancake còn "Mới"; ngược lại gắn thẻ + cảnh báo |
| Q8 | Tiền trên Pancake: USD hay VND, tỷ giá nguồn nào, theo ngày nào? | Giữ nguyên tiền tệ marketplace nếu shop Pancake hỗ trợ |
| Q9 | Mapping tự khớp có tự duyệt khi trùng mã chính xác không? | Có |
| Q10 | Ai đăng nhập miniapp, phân quyền thế nào? | Vai trò: Quản trị · Vận hành (map, đẩy lại, backfill) · Chỉ xem; giới hạn theo shop |
| Q11 | Lưu nhật ký bao lâu? | D1 180 ngày, R2 2 năm |
| Q12 | Cảnh báo gửi về nhóm Lark nào? | Nhóm vận hành Amazon, bot "HV Hub" |
| Q13 | Có cần realtime (P5, cần AWS) hay polling 5 phút là đủ? | Polling 5 phút |
| Q14 | Có muốn duyệt mockup giao diện trước khi code không? | Có, 1 file HTML click được theo style ops |
