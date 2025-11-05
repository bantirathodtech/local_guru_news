# Local Guru API Summary

**Developer:** Sai Sandeep A  
**Base URL:** `https://localguru.in/_api_v1/`

---

## 📋 Table of Contents

1. [Authentication APIs](#authentication-apis)
2. [User Management APIs](#user-management-apis)
3. [Location APIs](#location-apis)
4. [Editor APIs](#editor-apis)
5. [Post Management APIs](#post-management-apis)

---

## 🔐 Authentication APIs

### 1. Login API

**Endpoint:** `https://localguru.in/_api_v1/user/login_api.php`  
**Method:** `POST`  
**Body:** `form-data`

#### Parameters (Editor)
| Parameter | Value | Required |
|-----------|-------|----------|
| `email` | User email | ✅ |
| `password` | User password | ✅ |
| `role` | `editor` | ✅ |

#### Parameters (User)
| Parameter | Value | Required |
|-----------|-------|----------|
| `email` | User email | ✅ |
| `password` | User password | ✅ |
| `role` | `user` | ✅ |

---

### 2. Registration API

**Endpoint:** `https://localguru.in/_api_v1/user/registration_api.php`  
**Method:** `POST`  
**Body:** `form-data`

#### Parameters (Editor)
| Parameter | Value | Required |
|-----------|-------|----------|
| `name` | Full name | ✅ |
| `contact` | Phone number | ✅ |
| `email` | Email address | ✅ |
| `password` | Password | ✅ |
| `role` | `editor` | ✅ |
| `aadhar_number` | Aadhar number | ✅ |
| `address` | Address | ✅ |

#### Parameters (User)
| Parameter | Value | Required |
|-----------|-------|----------|
| `name` | Full name | ✅ |
| `contact` | Phone number | ✅ |
| `email` | Email address | ✅ |
| `password` | Password | ✅ |
| `role` | `user` | ✅ |
| `aadhar_number` | Aadhar number | ✅ |
| `address` | Address | ✅ |

---

### 3. Forgot Password API

**Endpoint:** `https://localguru.in/_api_v1/user/forgot_password_api.php`  
**Method:** `POST`  
**Body:** `form-data`

#### Parameters (Editor)
| Parameter | Value | Required |
|-----------|-------|----------|
| `email` | User email | ✅ |
| `role` | `editor` | ✅ |

#### Parameters (User)
| Parameter | Value | Required |
|-----------|-------|----------|
| `email` | User email | ✅ |
| `role` | `user` | ✅ |

---

### 4. Reset Password API

**Endpoint:** `https://localguru.in/_api_v1/user/reset_password_api.php`  
**Method:** `POST`  
**Body:** `form-data`

#### Parameters (Editor)
| Parameter | Value | Required |
|-----------|-------|----------|
| `email` | User email | ✅ |
| `role` | `editor` | ✅ |
| `otp` | OTP code | ✅ |
| `new_password` | New password | ✅ |

#### Parameters (User)
| Parameter | Value | Required |
|-----------|-------|----------|
| `email` | User email | ✅ |
| `role` | `user` | ✅ |
| `otp` | OTP code | ✅ |
| `new_password` | New password | ✅ |

---

## 👤 User Management APIs

### 5. Update Profile API

**Endpoint:** `https://localguru.in/_api_v1/user/update_profile_api.php`  
**Method:** `POST`  
**Body:** `form-data`

#### Parameters
| Parameter | Value | Required |
|-----------|-------|----------|
| `id` | User ID | ✅ |
| `name` | Full name | ✅ |
| `email` | Email address | ✅ |
| `role` | `editor` or `user` | ✅ |
| `aadhar_number` | Aadhar number | ✅ |
| `address` | Address | ✅ |
| `contact` | Phone number | ✅ |

---

## 🌍 Location APIs

### 6. Get States API

**Endpoint:** `https://localguru.in/_api_v1/user/get_states_api.php`  
**Method:** `GET`  
**Parameters:** None

---

### 7. Get Districts API

**Endpoint:** `https://localguru.in/_api_v1/user/get_districts_api.php`  
**Method:** `POST`  
**Body:** `form-data`

#### Parameters
| Parameter | Value | Required |
|-----------|-------|----------|
| `state_id` | State ID | ✅ |

---

### 8. Get Landmarks API

**Endpoint:** `https://localguru.in/_api_v1/user/get_landmars_api.php`  
**Method:** `POST`  
**Body:** `form-data`

#### Parameters
| Parameter | Value | Required |
|-----------|-------|----------|
| `State_id` | State ID | ✅ |
| `district_id` | District ID | ✅ |

**Note:** Parameter name is `State_id` (capital 'S'), not `state_id`.

---

### 9. Location API

**Endpoint:** `https://localguru.in/_api_v1/user/location_api.php`  
**Method:** `GET`  
**Parameters:** None

---

## ✏️ Editor APIs

### 10. Add States API

**Endpoint:** `https://localguru.in/_api_v1/editor/add_states_api.php`  
**Method:** `POST`  
**Body:** `form-data`

#### Parameters
| Parameter | Value | Required |
|-----------|-------|----------|
| `role` | `editor` | ✅ |
| `state` | State name (local language) | ✅ |
| `state_english` | State name (English) | ✅ |

---

### 11. Add Districts API

**Endpoint:** `https://localguru.in/_api_v1/editor/add_districts_api.php`  
**Method:** `POST`  
**Body:** `form-data`

#### Parameters
| Parameter | Value | Required |
|-----------|-------|----------|
| `role` | `editor` | ✅ |
| `state_id` | State ID | ✅ |
| `district` | District name (local language) | ✅ |
| `district_english` | District name (English) | ✅ |

---

### 12. Add Landmarks API

**Endpoint:** `https://localguru.in/_api_v1/editor/add_landmarks_api.php`  
**Method:** `POST`  
**Body:** `form-data`

#### Parameters
| Parameter | Value | Required |
|-----------|-------|----------|
| `role` | `editor` | ✅ |
| `state_id` | State ID | ✅ |
| `district_id` | District ID | ✅ |
| `landmark` | Landmark name (local language) | ✅ |
| `landmark_english` | Landmark name (English) | ✅ |

---

### 13. Add Topics API

**Endpoint:** `https://localguru.in/_api_v1/editor/add_topics_api.php`  
**Method:** `POST`  
**Body:** `form-data`

#### Parameters
| Parameter | Value | Required |
|-----------|-------|----------|
| `role` | `editor` | ✅ |
| `name` | Topic name (local language) | ✅ |
| `tags` | Comma-separated tags | ✅ |
| `icon` | Icon filename (e.g., `nature1.png`) | ✅ |

---

### 14. Add Post API

**Endpoint:** `https://localguru.in/_api_v1/editor/add_post_api.php`  
**Method:** `POST`  
**Body:** `form-data`

#### Common Parameters (All Layouts)
| Parameter | Value | Required |
|-----------|-------|----------|
| `id` | User/Editor ID | ✅ |
| `layout` | Layout type | ✅ |
| `title` | Post title | ✅ |
| `description` | Post description | ✅ |

#### Layout-Specific Parameters

**Layout: "Image with Description"**
| Parameter | Value | Required |
|-----------|-------|----------|
| `image` | Image filename (e.g., `weather1.png`) | ✅ |

**Layout: "Slider"**
| Parameter | Value | Required |
|-----------|-------|----------|
| `image` | Image filename (e.g., `weather1.png`) | ✅ |

**Layout: "Video"**
| Parameter | Value | Required |
|-----------|-------|----------|
| `video` | Video filename (e.g., `sample.mp4`) | ✅ |

**Layout: "Youtube"**
| Parameter | Value | Required |
|-----------|-------|----------|
| `link` | YouTube URL | ✅ |

---

## 📝 Notes

### Common Patterns

1. **Role-Based Authentication:** Most APIs require a `role` parameter (`editor` or `user`)
2. **Form Data:** All POST requests use `form-data` encoding (not JSON)
3. **Bilingual Support:** Location and topic APIs support both local language and English names
4. **Media Uploads:** File uploads (images, videos) use filename references, not direct binary uploads

### Important Observations

- The Get Landmarks API uses `State_id` (capital 'S') instead of `state_id` - this appears to be a naming inconsistency
- All authentication endpoints are under `/user/` path
- Editor-specific endpoints are under `/editor/` path
- Location data follows a hierarchical structure: State → District → Landmark

---

**Last Updated:** Based on API documentation provided  
**API Version:** v1 (`_api_v1`)

