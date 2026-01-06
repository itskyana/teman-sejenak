# Update API Auth (PHP CodeIgniter 3)

Update file `application/controllers/api/Auth.php` untuk mendukung session dengan token expiry.

## File: `application/controllers/api/Auth.php`

```php
<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Auth extends CI_Controller {

    // Token expiry time in seconds (24 hours)
    private $token_expiry = 86400;

    public function __construct()
    {
        parent::__construct();
        $this->load->model("User_model", "user");
    }

    /**
     * Register new user
     * POST /api/auth/register
     */
    public function register()
    {
        $input = json_decode(file_get_contents("php://input"), true);

        // Validate required fields
        if (
            !isset($input['full_name']) ||
            !isset($input['place_of_birth']) ||
            !isset($input['date_of_birth']) ||
            !isset($input['email']) ||
            !isset($input['password'])
        ) {
            response_json(400, "Semua field wajib diisi");
        }

        // Check if email already exists
        if ($this->user->get_by_email($input['email'])) {
            response_json(409, "Email sudah terdaftar");
        }

        // Validate email format
        if (!filter_var($input['email'], FILTER_VALIDATE_EMAIL)) {
            response_json(400, "Format email tidak valid");
        }

        // Validate password length
        if (strlen($input['password']) < 6) {
            response_json(400, "Password minimal 6 karakter");
        }

        $data = [
            "full_name"      => $input["full_name"],
            "place_of_birth" => $input["place_of_birth"],
            "date_of_birth"  => $input["date_of_birth"],
            "email"          => $input["email"],
            "password"       => password_hash($input["password"], PASSWORD_DEFAULT),
            "created_at"     => date("Y-m-d H:i:s"),
            "created_by"     => 0
        ];

        $id = $this->user->insert($data);

        // Generate token for auto-login after registration
        $token = $this->generate_token([
            "id"    => $id,
            "email" => $input["email"],
        ]);

        response_json(201, "User berhasil dibuat", [
            "token" => $token,
            "expires_in" => $this->token_expiry,
            "user" => [
                "id" => $id,
                "full_name" => $input["full_name"],
                "email" => $input["email"],
                "place_of_birth" => $input["place_of_birth"],
                "date_of_birth" => $input["date_of_birth"]
            ]
        ]);
    }

    /**
     * Login user
     * POST /api/auth/login
     */
    public function login()
    {
        $input = json_decode(file_get_contents("php://input"), true);

        if (!isset($input["email"]) || !isset($input["password"])) {
            response_json(400, "Email dan password wajib diisi");
        }

        $user = $this->user->get_by_email($input["email"]);

        if (!$user) {
            response_json(404, "User tidak ditemukan");
        }

        if (!password_verify($input["password"], $user->password)) {
            response_json(401, "Password salah");
        }

        // Generate token with expiry
        $token = $this->generate_token([
            "id"    => $user->id,
            "email" => $user->email,
        ]);

        // Update last login
        $this->user->update($user->id, [
            "last_login" => date("Y-m-d H:i:s")
        ]);

        response_json(200, "Login berhasil", [
            "token" => $token,
            "expires_in" => $this->token_expiry,
            "user" => [
                "id" => $user->id,
                "full_name" => $user->full_name,
                "email" => $user->email,
                "place_of_birth" => $user->place_of_birth ?? null,
                "date_of_birth" => $user->date_of_birth ?? null,
                "phone" => $user->phone ?? null,
                "image_url" => $user->image_url ?? null
            ]
        ]);
    }

    /**
     * Logout user
     * POST /api/auth/logout
     */
    public function logout()
    {
        // Verify token
        $user = $this->verify_token();
        
        if (!$user) {
            response_json(401, "Token tidak valid atau sudah expired");
        }

        // Optional: blacklist token or clear session on server
        // For JWT, you might want to store invalidated tokens in a blacklist table

        response_json(200, "Logout berhasil");
    }

    /**
     * Get user profile
     * GET /api/auth/profile
     */
    public function profile()
    {
        $user = $this->verify_token();
        
        if (!$user) {
            response_json(401, "Token tidak valid atau sudah expired");
        }

        $user_data = $this->user->get_by_id($user->id);

        if (!$user_data) {
            response_json(404, "User tidak ditemukan");
        }

        response_json(200, "Berhasil mengambil profile", [
            "user" => [
                "id" => $user_data->id,
                "full_name" => $user_data->full_name,
                "email" => $user_data->email,
                "place_of_birth" => $user_data->place_of_birth ?? null,
                "date_of_birth" => $user_data->date_of_birth ?? null,
                "phone" => $user_data->phone ?? null,
                "image_url" => $user_data->image_url ?? null,
                "created_at" => $user_data->created_at
            ]
        ]);
    }

    /**
     * Update user profile
     * PUT /api/auth/profile/update
     */
    public function profile_update()
    {
        $user = $this->verify_token();
        
        if (!$user) {
            response_json(401, "Token tidak valid atau sudah expired");
        }

        $input = json_decode(file_get_contents("php://input"), true);
        
        $update_data = [];
        
        if (isset($input['full_name']) && !empty($input['full_name'])) {
            $update_data['full_name'] = $input['full_name'];
        }
        if (isset($input['phone'])) {
            $update_data['phone'] = $input['phone'];
        }
        if (isset($input['image_url'])) {
            $update_data['image_url'] = $input['image_url'];
        }
        if (isset($input['place_of_birth'])) {
            $update_data['place_of_birth'] = $input['place_of_birth'];
        }
        if (isset($input['date_of_birth'])) {
            $update_data['date_of_birth'] = $input['date_of_birth'];
        }

        if (empty($update_data)) {
            response_json(400, "Tidak ada data yang diupdate");
        }

        $update_data['updated_at'] = date("Y-m-d H:i:s");

        $this->user->update($user->id, $update_data);

        // Get updated user data
        $user_data = $this->user->get_by_id($user->id);

        response_json(200, "Profile berhasil diupdate", [
            "user" => [
                "id" => $user_data->id,
                "full_name" => $user_data->full_name,
                "email" => $user_data->email,
                "place_of_birth" => $user_data->place_of_birth ?? null,
                "date_of_birth" => $user_data->date_of_birth ?? null,
                "phone" => $user_data->phone ?? null,
                "image_url" => $user_data->image_url ?? null
            ]
        ]);
    }

    /**
     * Refresh token
     * POST /api/auth/refresh
     */
    public function refresh()
    {
        $user = $this->verify_token();
        
        if (!$user) {
            response_json(401, "Token tidak valid atau sudah expired");
        }

        // Generate new token
        $new_token = $this->generate_token([
            "id"    => $user->id,
            "email" => $user->email,
        ]);

        response_json(200, "Token berhasil diperbarui", [
            "token" => $new_token,
            "expires_in" => $this->token_expiry
        ]);
    }

    // ══════════════════════════════════════════════════════════════
    // PRIVATE HELPER METHODS
    // ══════════════════════════════════════════════════════════════

    /**
     * Generate JWT token with expiry
     */
    private function generate_token($payload)
    {
        $payload['iat'] = time();                           // Issued at
        $payload['exp'] = time() + $this->token_expiry;     // Expiry time
        
        return generate_jwt($payload);
    }

    /**
     * Verify JWT token from Authorization header
     * Returns decoded payload if valid, null if invalid/expired
     */
    private function verify_token()
    {
        $headers = $this->input->request_headers();
        $auth_header = isset($headers['Authorization']) ? $headers['Authorization'] : 
                      (isset($headers['authorization']) ? $headers['authorization'] : null);

        if (!$auth_header) {
            return null;
        }

        // Remove "Bearer " prefix if present
        $token = str_replace('Bearer ', '', $auth_header);

        try {
            $decoded = decode_jwt($token);
            
            // Check if token is expired
            if (isset($decoded->exp) && $decoded->exp < time()) {
                return null;
            }
            
            return $decoded;
        } catch (Exception $e) {
            return null;
        }
    }
}
```

## Update `application/helpers/jwt_helper.php`

Pastikan helper JWT mendukung decode dan verifikasi expiry:

```php
<?php
defined('BASEPATH') OR exit('No direct script access allowed');

// Secret key - GANTI DENGAN KEY YANG AMAN!
define('JWT_SECRET', 'your-super-secret-key-change-this');

/**
 * Generate JWT token
 */
function generate_jwt($payload) {
    $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
    $payload = json_encode($payload);
    
    $base64Header = base64url_encode($header);
    $base64Payload = base64url_encode($payload);
    
    $signature = hash_hmac('sha256', "$base64Header.$base64Payload", JWT_SECRET, true);
    $base64Signature = base64url_encode($signature);
    
    return "$base64Header.$base64Payload.$base64Signature";
}

/**
 * Decode and verify JWT token
 */
function decode_jwt($token) {
    $parts = explode('.', $token);
    
    if (count($parts) !== 3) {
        throw new Exception('Invalid token format');
    }
    
    list($base64Header, $base64Payload, $base64Signature) = $parts;
    
    // Verify signature
    $signature = hash_hmac('sha256', "$base64Header.$base64Payload", JWT_SECRET, true);
    $expectedSignature = base64url_encode($signature);
    
    if (!hash_equals($expectedSignature, $base64Signature)) {
        throw new Exception('Invalid signature');
    }
    
    $payload = json_decode(base64url_decode($base64Payload));
    
    return $payload;
}

/**
 * Base64 URL-safe encode
 */
function base64url_encode($data) {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

/**
 * Base64 URL-safe decode
 */
function base64url_decode($data) {
    return base64_decode(strtr($data, '-_', '+/'));
}
```

## Update `application/models/User_model.php`

Tambahkan method yang diperlukan:

```php
<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class User_model extends CI_Model {

    private $table = 'users';

    public function get_by_id($id)
    {
        return $this->db->get_where($this->table, ['id' => $id])->row();
    }

    public function get_by_email($email)
    {
        return $this->db->get_where($this->table, ['email' => $email])->row();
    }

    public function insert($data)
    {
        $this->db->insert($this->table, $data);
        return $this->db->insert_id();
    }

    public function update($id, $data)
    {
        return $this->db->where('id', $id)->update($this->table, $data);
    }

    public function delete($id)
    {
        return $this->db->delete($this->table, ['id' => $id]);
    }
}
```

## Update Database Table `users`

Pastikan tabel users memiliki kolom yang diperlukan:

```sql
ALTER TABLE `users` 
ADD COLUMN `phone` VARCHAR(20) NULL AFTER `email`,
ADD COLUMN `image_url` TEXT NULL AFTER `phone`,
ADD COLUMN `last_login` DATETIME NULL AFTER `image_url`,
ADD COLUMN `updated_at` DATETIME NULL AFTER `created_at`;
```

## API Routes

Pastikan routes sudah dikonfigurasi di `application/config/routes.php`:

```php
// Auth routes
$route['api/auth/register'] = 'api/auth/register';
$route['api/auth/login'] = 'api/auth/login';
$route['api/auth/logout'] = 'api/auth/logout';
$route['api/auth/profile'] = 'api/auth/profile';
$route['api/auth/profile/update'] = 'api/auth/profile_update';
$route['api/auth/refresh'] = 'api/auth/refresh';
```

## Testing API

### Login
```bash
curl -X POST http://127.0.0.1/teman-sejenak/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@email.com","password":"password123"}'
```

Response:
```json
{
  "status": 200,
  "message": "Login berhasil",
  "data": {
    "token": "eyJ0eXAi...",
    "expires_in": 86400,
    "user": {
      "id": 1,
      "full_name": "John Doe",
      "email": "test@email.com",
      ...
    }
  }
}
```

### Get Profile (with token)
```bash
curl -X GET http://127.0.0.1/teman-sejenak/api/auth/profile \
  -H "Authorization: Bearer <token>"
```

### Logout
```bash
curl -X POST http://127.0.0.1/teman-sejenak/api/auth/logout \
  -H "Authorization: Bearer <token>"
```
