<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>

<html lang="ms">

<head>

    <meta charset="UTF-8">

    <meta

        name="viewport"

        content="width=device-width, initial-scale=1.0"

    >

    <title>

        Log Masuk - PKB Staff Management System

    </title>

    <link

    rel="stylesheet"

    href="<%= request.getContextPath() %>/css/style.css?v=20260914-unified"

/>

    <style>
* { box-sizing: border-box; }

body.login-page {
    min-height: 100vh;
    margin: 0;
    padding: 22px 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: "Segoe UI", Arial, sans-serif;
    color: #172033;
    background:
        radial-gradient(circle at top left, rgba(213,161,43,.10), transparent 32%),
        radial-gradient(circle at bottom right, rgba(141,31,45,.08), transparent 35%),
        #f6f7fa;
}

.login-card {
    position: relative;
    width: 100%;
    max-width: 450px;
    padding: 30px 36px 28px;
    overflow: hidden;
    background: #fff;
    border: 1px solid #e7e9ef;
    border-radius: 18px;
    box-shadow: 0 16px 45px rgba(30,39,57,.09);
}

.login-card::before {
    content: "";
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 4px;
    background: linear-gradient(90deg,#8d1f2d,#d5a12b,#8d1f2d);
}

.logo-center { text-align: center; }

.login-logo {
    width: 145px;
    max-width: 55%;
    height: auto;
    object-fit: contain;
}

.system-title {
    margin: 19px 0 6px;
    color: #172033;
    text-align: center;
    font-size: 25px;
    line-height: 1.15;
    font-weight: 750;
    letter-spacing: -.35px;
}

.system-title span { color: #8d1f2d; }

.welcome-text {
    margin: 0 0 21px;
    color: #8a94a5;
    text-align: center;
    font-size: 13px;
    line-height: 1.45;
}

.success-message,
.error-message {
    margin-bottom: 14px;
    padding: 10px 12px;
    border-radius: 9px;
    font-size: 12px;
    line-height: 1.5;
}

.success-message {
    background: #eaf8f1;
    border: 1px solid #cde9da;
    color: #236f4b;
}

.error-message {
    background: #fff0f2;
    border: 1px solid #efcdd2;
    color: #a72d39;
}

.login-form {
    display: flex;
    flex-direction: column;
}

.form-group { margin-bottom: 14px; }

.form-group label {
    display: block;
    margin-bottom: 6px;
    color: #3f495b;
    font-size: 12.5px;
    line-height: 1.35;
    font-weight: 650;
}

.form-group input {
    width: 100%;
    height: 42px;
    padding: 0 13px;
    background: #fff;
    border: 1px solid #dfe3e9;
    border-radius: 9px;
    color: #333d50;
    font-family: inherit;
    font-size: 12.5px;
    outline: none;
    transition: border-color .15s ease, box-shadow .15s ease, background .15s ease;
}

.form-group input::placeholder {
    color: #a1a8b3;
    font-size: 12.5px;
}

.form-group input:focus {
    border-color: #a84754;
    box-shadow: 0 0 0 3px rgba(141,31,45,.08);
    background: #fffefe;
}

.password-wrapper { position: relative; }
.password-wrapper input { padding-right: 78px; }

.password-toggle {
    position: absolute;
    right: 9px;
    top: 50%;
    transform: translateY(-50%);
    padding: 5px 7px;
    background: transparent;
    border: 0;
    color: #8d1f2d;
    font-family: inherit;
    font-size: 11.5px;
    font-weight: 700;
    cursor: pointer;
}

.password-toggle:hover { color: #701722; }

.login-button {
    width: 100%;
    height: 41px;
    margin-top: 2px;
    border: 1px solid #8d1f2d;
    border-radius: 9px;
    background: linear-gradient(135deg,#8d1f2d,#a72a3b);
    color: #fff;
    font-family: inherit;
    font-size: 12.5px;
    font-weight: 700;
    cursor: pointer;
    box-shadow: 0 4px 12px rgba(141,31,45,.16);
    transition: background .15s ease, transform .15s ease, box-shadow .15s ease;
}

.login-button:hover:not(:disabled) {
    background: linear-gradient(135deg,#701722,#8d1f2d);
    transform: translateY(-1px);
    box-shadow: 0 6px 15px rgba(141,31,45,.20);
}

.login-button:disabled {
    opacity: .7;
    cursor: not-allowed;
}

.login-divider {
    display: flex;
    align-items: center;
    gap: 10px;
    margin: 19px 0 14px;
    color: #9aa2af;
    font-size: 11px;
}

.login-divider::before,
.login-divider::after {
    content: "";
    flex: 1;
    height: 1px;
    background: #eceef2;
}

.register-section { text-align: center; }

.register-text {
    display: block;
    margin-bottom: 8px;
    color: #8a94a5;
    font-size: 11.5px;
}

.register-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 41px;
    background: #fff;
    border: 1px solid #d6bfc3;
    border-radius: 9px;
    color: #8d1f2d;
    text-decoration: none;
    font-size: 12.5px;
    font-weight: 700;
    transition: background .15s ease, border-color .15s ease, transform .15s ease;
}

.register-btn:hover {
    background: #fff7f8;
    border-color: #b96a75;
    transform: translateY(-1px);
}

.login-footer {
    margin-top: 17px;
    color: #a0a7b2;
    text-align: center;
    font-size: 10.5px;
}

@media (max-width: 520px) {
    body.login-page {
        min-height: 100vh;
        min-height: 100svh;
        padding: 10px;
        align-items: flex-start;
    }

    .login-card {
        width: 100%;
        max-width: 360px;
        margin: auto;
        padding: 17px 18px 15px;
        border-radius: 14px;
    }

    .login-logo { width: 102px; }

    .system-title {
        margin: 10px 0 4px;
        font-size: 19px;
        line-height: 1.15;
    }

    .welcome-text { margin-bottom: 12px; font-size: 12px; }
    .form-group { margin-bottom: 9px; }

    .form-group label {
        margin-bottom: 4px;
        font-size: 11.5px;
    }

    .form-group input {
        height: 39px;
        font-size: 14px;
    }

    .form-group input::placeholder { font-size: 13px; }
    .password-toggle { font-size: 11px; }
    .login-button { height: 39px; font-size: 12px; }
    .login-divider { margin: 11px 0 8px; }
    .register-text { margin-bottom: 5px; font-size: 11px; }
    .register-btn { height: 39px; font-size: 12px; }
    .login-footer { margin-top: 10px; font-size: 10px; }
}

@media (max-width: 360px) {
    body.login-page { padding: 8px; }
    .login-card { padding: 15px 14px 14px; }
    .login-logo { width: 94px; }
    .system-title { font-size: 18px; }
}
</style>

</head>

<body class="login-page">

<div class="login-card">

    <!-- =====================================================

         LOGO PKB

         \===================================================== -->

    <div class="brand logo-center">

        <img

            src="<%= request.getContextPath() %>/images/logo-pkb.png"

            alt="Permodalan Kedah Berhad"

            class="login-logo"

        >

    </div>

    <!-- =====================================================

         TITLE

         \===================================================== -->

    <h1 class="system-title">

        PKB Staff

        <br>

        <span>

            Management System

        </span>

    </h1>

    <p class="welcome-text">

        Selamat Datang

    </p>

    <!-- =====================================================

         REGISTER SUCCESS

         \===================================================== -->

    <% if ("registered".equals(request.getParameter("success"))) { %>

        <div class="success-message">

            Akaun berjaya didaftarkan.

            Anda kini boleh log masuk menggunakan e-mel dan kata laluan anda.

        </div>

    <% } %>

    <!-- =====================================================

         PASSWORD CHANGED

         \===================================================== -->

    <% if ("passwordChanged".equals(request.getParameter("success"))) { %>

        <div class="success-message">

            Kata laluan berjaya ditukar.

            Sila log masuk menggunakan kata laluan baharu anda.

        </div>

    <% } %>

    <!-- =====================================================

         ERROR

         \===================================================== -->

    <% if ("1".equals(request.getParameter("error"))) { %>

        <div class="error-message">

            E-mel atau kata laluan tidak sah.

        </div>

    <% } %>

    <!-- =====================================================

         LOGIN FORM

         \===================================================== -->

    <form

        method="post"

        action="<%= request.getContextPath() %>/login"

        id="loginForm"

        class="login-form"

    >

        <!-- EMAIL -->

        <div class="form-group">

            <label for="email">

                E-mel

            </label>

            <input

                name="email"

                id="email"

                type="email"

                placeholder="nama@pkb.my"

                autocomplete="email"

                maxlength="160"

                required

            >

        </div>

        <!-- PASSWORD -->

        <div class="form-group">

            <label for="password">

                Kata Laluan

            </label>

            <div class="password-wrapper">

                <input

                    name="password"

                    id="password"

                    type="password"

                    placeholder="Masukkan kata laluan"

                    autocomplete="current-password"

                    maxlength="100"

                    required

                >

                <button

                    type="button"

                    class="password-toggle"

                    id="passwordToggle"

                >

                    Papar

                </button>

            </div>

        </div>

        <!-- LOGIN BUTTON -->

        <button

            type="submit"

            class="login-button"

            id="loginButton"

        >

            Log Masuk

        </button>

    </form>

    <!-- =====================================================

         DIVIDER

         \===================================================== -->

    <div class="login-divider">

        atau

    </div>

    <!-- =====================================================

         REGISTER

         \===================================================== -->

    <div class="register-section">

        <span class="register-text">

            Staf baharu?

        </span>

        <a

            href="<%= request.getContextPath() %>/register"

            class="register-btn"

        >

            Daftar Akaun Baharu

        </a>

    </div>

    <div class="login-footer">

        Permodalan Kedah Berhad

    </div>

</div>

<script>

    // =========================================================

    // PASSWORD SHOW / HIDE

    // =========================================================

    const passwordInput =

        document.getElementById(

            "password"

        );

    const passwordToggle =

        document.getElementById(

            "passwordToggle"

        );

    passwordToggle.addEventListener(

        "click",

        function () {

            if (

                passwordInput.type ===

                "password"

            ) {

                passwordInput.type =

                    "text";

                passwordToggle.textContent =

                    "Sembunyi";

            } else {

                passwordInput.type =

                    "password";

                passwordToggle.textContent =

                    "Papar";

            }

        }

    );

    // =========================================================

    // PREVENT DOUBLE SUBMIT

    // =========================================================

    document

        .getElementById(

            "loginForm"

        )

        .addEventListener(

            "submit",

            function () {

                const loginButton =

                    document.getElementById(

                        "loginButton"

                    );

                loginButton.disabled =

                    true;

                loginButton.textContent =

                    "Sedang Log Masuk...";

            }

        );

</script>

</body>

</html>
