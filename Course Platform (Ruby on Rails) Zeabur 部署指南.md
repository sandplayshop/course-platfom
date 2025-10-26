# Course Platform (Ruby on Rails) Zeabur 部署指南

本指南將引導您將 Course Platform 專案部署到 Zeabur 平台。

## 1. 專案準備

您的專案已包含以下針對 Zeabur 部署優化的檔案：

*   **`Dockerfile`**: 定義了 Docker 映像的建構步驟，Zeabur 會自動使用它來部署您的服務。
*   **`Procfile`**: 定義了 Web 服務的啟動命令 (`web: bundle exec puma -C config/puma.rb`)。
*   **`.dockerignore`**: 排除不必要的檔案，加速建構過程。

## 2. Zeabur 部署步驟

### 步驟 2.1: 程式碼上傳

1.  **初始化 Git 倉庫**：
    ```bash
    git init
    git add .
    git commit -m "Initial commit for Zeabur deployment"
    ```
2.  **上傳到 Git 平台**：
    將您的專案上傳到您選擇的 Git 平台（如 GitHub, GitLab 或 Bitbucket）。

### 步驟 2.2: 在 Zeabur 上創建服務

1.  **登入 Zeabur**：登入您的 Zeabur 帳號。
2.  **創建專案**：在您的 Zeabur 空間中創建一個新的專案。
3.  **添加服務**：在專案中，點擊 **Add Service**。
4.  **選擇部署方式**：選擇 **Deploy with Git**，並連結您的 Git 倉庫。
5.  **選擇服務類型**：Zeabur 會自動偵測到 `Dockerfile`，並將其識別為 **Web Service**。
6.  **配置服務**：
    *   **Port**: 預設為 `3000` (Rails Puma 服務的預設端口)。
    *   **Build Type**: 選擇 **Docker**。

### 步驟 2.3: 添加 PostgreSQL 資料庫服務

1.  在同一個 Zeabur 專案中，點擊 **Add Service**，選擇 **PostgreSQL**。
2.  等待 PostgreSQL 服務部署完成。

### 步驟 2.4: 配置環境變數

Zeabur 的服務之間可以自動建立連線，但您仍需要設定一些關鍵的環境變數，特別是與綠界金流相關的變數。

在您的 **Web Service** 設定頁面中，導航到 **Variables**，添加以下變數：

| 變數名稱 | 範例值/說明 | 備註 |
| :--- | :--- | :--- |
| `RAILS_MASTER_KEY` | (您的 Rails 加密主密鑰) | 運行 Rails 應用程式所需。 |
| `RAILS_ENV` | `production` | 設定為生產環境。 |
| `SECRET_KEY_BASE` | (一個長且隨機的字串) | Rails 應用程式的 Session 密鑰。 |
| `DATABASE_URL` | (Zeabur 自動注入) | Zeabur 會自動注入 PostgreSQL 的連線 URL，無需手動設定。 |
| `ECPAY_MERCHANT_ID` | `2000132` (測試用) | 您的綠界商店代號。 |
| `ECPAY_HASH_KEY` | `5294y06JbISpM5x9` (測試用) | 您的綠界 Hash Key。 |
| `ECPAY_HASH_IV` | `v77hoKGq4kWxNNIS` (測試用) | 您的綠界 Hash IV。 |

**注意：** 上述綠界的值是測試環境的範例。在正式部署時，請務必替換為您正式申請的 **正式環境** 參數。

### 步驟 2.5: 執行資料庫遷移

在 Web Service 部署成功後，您需要執行資料庫遷移來建立資料表。

1.  在 Web Service 的 **Terminal** 頁面中，執行以下命令：
    ```bash
    bundle exec rails db:migrate
    ```
2.  **一鍵管理員帳號創建 (可選)**：如果您需要創建一個管理員帳號，可以使用 Rails Console：
    ```bash
    bundle exec rails console
    # 在 Console 中執行：
    User.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password', points: 9999)
    # exit
    ```

## 3. 一鍵安裝指令 (總結)

由於 Zeabur 採用 GitOps 流程，部署是透過 Git 倉庫和 Web 介面完成的，沒有單一的「一鍵安裝指令」。您需要遵循以下流程：

1.  **本地**：`git init` -> `git add .` -> `git commit`
2.  **遠端**：將程式碼推送到 Git 倉庫。
3.  **Zeabur**：
    *   創建 **Web Service** (連結 Git 倉庫)。
    *   創建 **PostgreSQL Service**。
    *   設定 **環境變數** (特別是綠界參數)。
    *   在 Terminal 中執行 `bundle exec rails db:migrate`。

完成上述步驟後，您的網站將會成功部署並運行。

