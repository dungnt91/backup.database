# HV Hub — Anh cần chuẩn bị và chốt gì trước khi code

> Đi kèm [GIAI_PHAP.md](GIAI_PHAP.md) v0.3. Tick từng mục; mục nào để trống em dùng **đề xuất mặc định**.
> **Không gửi secret qua chat hay commit lên git.** Secret Amazon/Pancake nhập trên miniapp (lưu mã hoá); secret Cloudflare đặt bằng `npx wrangler secret put`.

## A. Amazon (yêu cầu #1, #2, #5, #10) — đã chốt

Anh nhập trên **Cấu hình → Kết nối Amazon**, mỗi shop 1 dòng, cùng bộ trường như `Amazon_Configs`:

| # | Trường | Ghi chú |
|---|---|---|
| A1 | **ShopName** | |
| A2 | **ClientId** | |
| A3 | **ClientSecret** | + ngày hết hạn (để cảnh báo xoay vòng) |
| A4 | **MarketplaceIds** | Region tự suy ra, không cần nhập |
| A5 | **RefreshToken** | ⚠️ **Bắt buộc phải có thêm trường này.** ClientId/ClientSecret chỉ là "chìa khoá app"; RefreshToken là quyền shop cấp cho app. Thiếu thì Amazon không trả dữ liệu. Lấy từ `Amazon_Configs.RefreshToken` hiện tại |

Kiểm tra role của app (Developer profile) theo dữ liệu chọn ở câu Q2:
- Bắt buộc (đơn + sản phẩm): **Inventory and Order Tracking**, **Product Listing**.
- Nếu chọn hoàn hàng / tồn FBA / lô hàng FBA: **Amazon Fulfillment**. Tài chính / settlement: **Finance and Accounting**. Doanh số & traffic: **Brand Analytics**. Giá: **Pricing**.
- **Không cần** role PII (Direct-to-Consumer Shipping).
- Thêm role mới thì phải **authorize lại** app cho shop để có RefreshToken mới.
- Nút **Test kết nối** trên miniapp sẽ báo thiếu role nào.

## B. Pancake POS (yêu cầu #3, #11)

| # | Thông tin | Ghi chú |
|---|---|---|
| B1 | `SHOP_ID` + `api_key` của từng shop Pancake nhận đơn Amazon | **Anh tự nhập** trên Cấu hình → Pancake (4 bước: kết nối · tuyến đơn · khách & địa chỉ · ánh xạ trạng thái — GIAI_PHAP.md mục 5.4) |
| B2 | **1 shop Pancake thử** (hoặc cho phép tạo đơn thử rồi huỷ trên shop thật) | Bắt buộc để kiểm trường tạo đơn trước khi đẩy thật |
| B3 | Shop/marketplace Amazon nào đổ về shop Pancake nào | Cấu hình ở bước 2 |
| B4 | Kho nhận đơn FBA và FBM | Chọn ở bước 2 (danh sách lấy từ Pancake) |
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
| Q2 | ~~Ngoài đơn hàng, cần dữ liệu nào?~~ **Chốt: bắt buộc sản phẩm + đơn hàng.** Còn lại anh chọn trong bảng D3–D10 (GIAI_PHAP.md mục 3.2) | Thêm D3 hoàn hàng, D4 tồn FBA, D5 tài chính |
| Q3 | ~~Có cần PII?~~ **Chốt: không**, Amazon đã ẩn | — |
| Q4 | ~~Trạng thái nào thì đẩy?~~ Gộp vào bảng ánh xạ trạng thái (bước 4) | Không đẩy `PENDING` |
| Q5 | ~~Địa chỉ trên Pancake?~~ **Chốt: dùng khách + địa chỉ có sẵn trên Pancake**, cấu hình ánh xạ ở bước 3 | — |
| Q6 | ~~Ánh xạ trạng thái?~~ **Chốt: có bước cấu hình ánh xạ trạng thái** (bước 4). Anh + bên kho tự điền trên miniapp | Không đẩy `PENDING` |
| Q7 | ~~Đơn huỷ sau khi Pancake đã xử lý?~~ Gộp vào tuỳ chọn "Khi đơn Pancake đã đi xa hơn" ở bước 4 | Bỏ qua + cảnh báo |
| Q8 | Tiền trên Pancake: USD hay VND, tỷ giá nguồn nào, theo ngày nào? | Giữ nguyên tiền tệ marketplace nếu shop Pancake hỗ trợ |
| Q9 | Mapping tự khớp có tự duyệt khi trùng mã chính xác không? | Có |
| Q10 | Ai đăng nhập miniapp, phân quyền thế nào? | Vai trò: Quản trị · Vận hành (map, đẩy lại, backfill) · Chỉ xem; giới hạn theo shop |
| Q11 | Lưu nhật ký bao lâu? | D1 180 ngày, R2 2 năm |
| Q12 | Cảnh báo gửi về nhóm Lark nào? | Nhóm vận hành Amazon, bot "HV Hub" |
| Q13 | Có cần realtime (P5, cần AWS) hay polling 5 phút là đủ? | Polling 5 phút |
| Q14 | Có muốn duyệt mockup giao diện trước khi code không? | Có, 1 file HTML click được theo style ops |
