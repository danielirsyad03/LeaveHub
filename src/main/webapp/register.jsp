<%@ page contentType="text/html;charset=UTF-8" %>

<%!

    private String h(Object value) {

        if (value == null) {

            return "";

        }

        return String.valueOf(value)

                .replace("&", "&amp;")

                .replace("\"", "&quot;")

                .replace("'", "&#39;")

                .replace("<", "&lt;")

                .replace(">", "&gt;");

    }

%>

<%

    @SuppressWarnings("unchecked")

    java.util.List<java.util.Map<String, Object>> hods =

        (java.util.List<java.util.Map<String, Object>>)

        request.getAttribute("hods");

    String error =

        request.getParameter("error");

    String formName =

        request.getParameter("name") != null

            ? request.getParameter("name")

            : "";

    String formPosition =

        request.getParameter("position") != null

            ? request.getParameter("position")

            : "";

    String formEmail =

        request.getParameter("email") != null

            ? request.getParameter("email")

            : "";

    String formDepartment =

        request.getParameter("department") != null

            ? request.getParameter("department")

            : "";

    String formHodId =

        request.getParameter("hodId") != null

            ? request.getParameter("hodId")

            : "";

%>

<!DOCTYPE html>

<html lang="ms">

<head>

    <meta charset="UTF-8">

    <meta

        name="viewport"

        content="width=device-width, initial-scale=1.0"

    >

    <title>

        Daftar Akaun Staf - PKB Staff Management System

    </title>

    <link

    rel="stylesheet"

    href="<%= request.getContextPath() %>/css/style.css?v=20260914-unified"

/>

    <style>
*{box-sizing:border-box}
body.login-page{min-height:100vh;margin:0;padding:22px 16px;display:flex;align-items:flex-start;justify-content:center;font-family:"Segoe UI",Arial,sans-serif;color:#172033;background:radial-gradient(circle at top left,rgba(213,161,43,.10),transparent 32%),radial-gradient(circle at bottom right,rgba(141,31,45,.08),transparent 35%),#f6f7fa}
.register-card{position:relative;width:100%;max-width:560px;padding:27px 34px 25px;overflow:hidden;background:#fff;border:1px solid #e7e9ef;border-radius:18px;box-shadow:0 16px 45px rgba(30,39,57,.09)}
.register-card:before{content:"";position:absolute;inset:0 0 auto;height:4px;background:linear-gradient(90deg,#8d1f2d,#d5a12b,#8d1f2d)}
.logo-center{text-align:center}.login-logo{width:138px;max-width:55%;height:auto;object-fit:contain}
.register-title{margin:17px 0 4px;color:#172033;text-align:center;font-size:26px;line-height:1.25;font-weight:750;letter-spacing:-.3px}
.register-subtitle{margin:0 0 17px;color:#8a94a5;text-align:center;font-size:13px;line-height:1.45}
.register-note,.register-error{margin-bottom:15px;padding:11px 13px;border-radius:9px;font-size:12.5px;line-height:1.55}
.register-note{background:linear-gradient(135deg,#fffafa,#fffdf7);border:1px solid #eadde0;color:#717c8e}.register-note strong{color:#8d1f2d}
.register-error{background:#fff0f2;border:1px solid #efcdd2;color:#a72d39}
.register-form-group{margin-bottom:13px}.register-form-group label{display:block;margin-bottom:6px;color:#3f495b;font-size:12.5px;line-height:1.35;font-weight:650}
.optional-label{margin-left:4px;color:#929aa8;font-size:11.5px;font-weight:500}
.register-form-group input,.register-form-group select{width:100%;height:42px;padding:0 13px;background:#fff;border:1px solid #dfe3e9;border-radius:9px;color:#333d50;font-family:inherit;font-size:12.5px;outline:none;transition:.15s}
.register-form-group input::placeholder{color:#a1a8b3;font-size:12.5px}.register-form-group input:focus,.register-form-group select:focus{border-color:#a84754;box-shadow:0 0 0 3px rgba(141,31,45,.08)}
.register-form-group select:disabled{background:#f3f4f6;color:#a0a7b1;cursor:not-allowed}.field-note,.password-note{color:#8d96a5;font-size:11.5px;line-height:1.4}.field-note{margin-top:5px}
.password-wrapper{position:relative}.password-wrapper input{padding-right:76px}.password-toggle{position:absolute;right:9px;top:50%;transform:translateY(-50%);padding:5px 7px;border:0;background:transparent;color:#8d1f2d;font-family:inherit;font-size:11.5px;font-weight:700;cursor:pointer}.password-toggle:hover{color:#701722}.password-note{margin-top:-5px;margin-bottom:13px}
.register-actions{margin-top:17px}.register-button,.back-login{width:100%;height:41px;border-radius:9px;font-family:inherit;font-size:12.5px;font-weight:700}.register-button{border:1px solid #8d1f2d;background:linear-gradient(135deg,#8d1f2d,#a72a3b);color:#fff;cursor:pointer;box-shadow:0 4px 12px rgba(141,31,45,.16)}.register-button:hover:not(:disabled){background:linear-gradient(135deg,#701722,#8d1f2d)}.register-button:disabled{opacity:.7;cursor:not-allowed}
.back-login{display:flex;align-items:center;justify-content:center;margin-top:11px;background:#fff;border:1px solid #d6bfc3;color:#8d1f2d;text-decoration:none}.back-login:hover{background:#fff7f8}.register-footer{margin-top:16px;color:#a0a7b2;text-align:center;font-size:10.5px}
@media(max-width:620px){body.login-page{padding:14px 10px}.register-card{padding:24px 20px 22px;border-radius:15px}.register-title{font-size:23px}.login-logo{width:128px}}
</style>

</head>

<body class="login-page">

<div class="register-card">

    <!-- LOGO -->

    <div class="logo-center">

        <img

            src="<%= request.getContextPath() %>/images/logo-pkb.png"

            alt="Permodalan Kedah Berhad"

            class="login-logo"

        >

    </div>

    <!-- TITLE -->

    <h1 class="register-title">

        Daftar Akaun Staf

    </h1>

    <p class="register-subtitle">

        PKB Staff Management System

    </p>

    <!-- NOTE -->

    <div class="register-note">

        Pendaftaran ini adalah untuk akaun

        <strong>Staf</strong>

        sahaja.

        Akaun

        <strong>Ketua Unit</strong>,

        <strong>Pengurusan</strong>

        dan

        <strong>Pentadbir Sistem</strong>

        diuruskan oleh pihak Pentadbiran.

        <br><br>

        <strong>

            Ketua Unit adalah pilihan.

        </strong>

        Jika Ketua Unit belum ditetapkan untuk jabatan anda,

        pendaftaran masih boleh diteruskan.

    </div>

    <!-- ERRORS -->

    <% if ("required".equals(error)) { %>

        <div class="register-error">

            Sila lengkapkan semua maklumat wajib.

        </div>

    <% } %>

    <% if ("nameLength".equals(error)) { %>

        <div class="register-error">

            Nama yang dimasukkan terlalu panjang.

        </div>

    <% } %>

    <% if ("positionLength".equals(error)) { %>

        <div class="register-error">

            Jawatan yang dimasukkan terlalu panjang.

        </div>

    <% } %>

    <% if ("password".equals(error)) { %>

        <div class="register-error">

            Kata laluan dan pengesahan kata laluan tidak sepadan.

        </div>

    <% } %>

    <% if ("passwordLength".equals(error)) { %>

        <div class="register-error">

            Kata laluan mestilah mempunyai sekurang-kurangnya 6 aksara.

        </div>

    <% } %>

    <% if ("invalidEmail".equals(error)) { %>

        <div class="register-error">

            Sila masukkan alamat e-mel yang sah.

        </div>

    <% } %>

    <% if ("emailExists".equals(error)) { %>

        <div class="register-error">

            E-mel ini telah didaftarkan.

        </div>

    <% } %>

    <% if ("department".equals(error)) { %>

        <div class="register-error">

            Sila pilih jabatan yang sah.

        </div>

    <% } %>

    <% if ("hod".equals(error)) { %>

        <div class="register-error">

            Ketua Unit yang dipilih tidak sah untuk jabatan anda.

            Anda boleh membiarkan ruangan Ketua Unit kosong.

        </div>

    <% } %>

    <% if ("quota".equals(error)) { %>

        <div class="register-error">

            Akaun tidak dapat dicipta kerana kuota cuti awal

            tidak dapat diwujudkan.

        </div>

    <% } %>

    <% if ("system".equals(error)) { %>

        <div class="register-error">

            Pendaftaran tidak berjaya. Sila cuba semula.

        </div>

    <% } %>

    <!-- REGISTER FORM -->

    <form

        method="post"

        action="<%= request.getContextPath() %>/register"

        id="registerForm"

    >

        <!-- NAME -->

        <div class="register-form-group">

            <label for="name">

                Nama Penuh *

            </label>

            <input

                type="text"

                id="name"

                name="name"

                value="<%= h(formName) %>"

                placeholder="Masukkan nama penuh"

                maxlength="120"

                autocomplete="name"

                required

            >

        </div>

        <!-- POSITION -->

        <div class="register-form-group">

            <label for="position">

                Jawatan *

            </label>

            <input

                type="text"

                id="position"

                name="position"

                value="<%= h(formPosition) %>"

                placeholder="Contoh: Eksekutif"

                maxlength="150"

                required

            >

        </div>

        <!-- EMAIL -->

        <div class="register-form-group">

            <label for="email">

                E-mel *

            </label>

            <input

                type="email"

                id="email"

                name="email"

                value="<%= h(formEmail) %>"

                placeholder="nama@pkb.my"

                maxlength="160"

                autocomplete="email"

                required

            >

        </div>

        <!-- PASSWORD -->

        <div class="register-form-group">

            <label for="password">

                Kata Laluan *

            </label>

            <div class="password-wrapper">

                <input

                    type="password"

                    id="password"

                    name="password"

                    placeholder="Minimum 6 aksara"

                    minlength="6"

                    maxlength="100"

                    autocomplete="new-password"

                    required

                >

                <button

                    type="button"

                    class="password-toggle"

                    data-target="password"

                >

                    Lihat

                </button>

            </div>

        </div>

        <!-- CONFIRM PASSWORD -->

        <div class="register-form-group">

            <label for="confirmPassword">

                Sahkan Kata Laluan *

            </label>

            <div class="password-wrapper">

                <input

                    type="password"

                    id="confirmPassword"

                    name="confirmPassword"

                    placeholder="Masukkan semula kata laluan"

                    minlength="6"

                    maxlength="100"

                    autocomplete="new-password"

                    required

                >

                <button

                    type="button"

                    class="password-toggle"

                    data-target="confirmPassword"

                >

                    Lihat

                </button>

            </div>

        </div>

        <div class="password-note">

            Kata laluan mestilah mempunyai

            sekurang-kurangnya 6 aksara.

        </div>

        <!-- DEPARTMENT -->

        <div class="register-form-group">

            <label for="department">

                Jabatan *

            </label>

            <select

                name="department"

                id="department"

                required

            >

                <option value="">

                    Pilih Jabatan

                </option>

                <option

                    value="PENTADBIRAN_KORPORAT"

                    <%= "PENTADBIRAN_KORPORAT".equals(

                        formDepartment

                    ) ? "selected" : "" %>

                >

                    Pentadbiran dan Korporat

                </option>

                <option

                    value="KEWANGAN"

                    <%= "KEWANGAN".equals(

                        formDepartment

                    ) ? "selected" : "" %>

                >

                    Kewangan

                </option>

                <option

                    value="PEMBANGUNAN_PERNIAGAAN_OPERASI"

                    <%= "PEMBANGUNAN_PERNIAGAAN_OPERASI".equals(

                        formDepartment

                    ) ? "selected" : "" %>

                >

                    Pembangunan Perniagaan dan Operasi

                </option>

            </select>

        </div>

        <!-- HOD OPTIONAL -->

        <div class="register-form-group">

            <label for="hodId">

                Ketua Unit

                <span class="optional-label">

                    (Pilihan)

                </span>

            </label>

            <select

                name="hodId"

                id="hodId"

                disabled

            >

                <option value="">

                    Pilih Jabatan Terlebih Dahulu

                </option>

                <%

                    if (hods != null) {

                        for (

                            java.util.Map<String, Object> hod :

                            hods

                        ) {

                            String hodDepartment =

                                hod.get("department") == null

                                    ? ""

                                    : String.valueOf(

                                        hod.get("department")

                                    );

                            String hodId =

                                hod.get("id") == null

                                    ? ""

                                    : String.valueOf(

                                        hod.get("id")

                                    );

                            String hodName =

                                hod.get("name") == null

                                    ? "Ketua Unit"

                                    : String.valueOf(

                                        hod.get("name")

                                    );

                %>

                    <option

                        value="<%= h(hodId) %>"

                        data-department="<%= h(hodDepartment) %>"

                    >

                        <%= h(hodName) %>

                    </option>

                <%

                        }

                    }

                %>

            </select>

            <div class="field-note">

                Tidak wajib.

                Jika Ketua Unit belum ditetapkan,

                pilihan ini boleh dibiarkan kosong.

            </div>

        </div>

        <!-- SUBMIT -->

        <div class="register-actions">

            <button

                type="submit"

                class="register-button"

                id="registerButton"

            >

                Daftar Akaun

            </button>

        </div>

    </form>

    <a

        href="<%= request.getContextPath() %>/"

        class="back-login"

    >

        Kembali ke Log Masuk

    </a>

    <div class="register-footer">

        Permodalan Kedah Berhad

    </div>

</div>

<script>

document.addEventListener(

    "DOMContentLoaded",

    function() {

        const department =

            document.getElementById(

                "department"

            );

        const hodSelect =

            document.getElementById(

                "hodId"

            );

        const registerForm =

            document.getElementById(

                "registerForm"

            );

        const registerButton =

            document.getElementById(

                "registerButton"

            );

        const password =

            document.getElementById(

                "password"

            );

        const confirmPassword =

            document.getElementById(

                "confirmPassword"

            );

        // =====================================================

        // STORE ALL HOD OPTIONS

        // =====================================================

        const allHodOptions =

            Array.from(

                hodSelect.querySelectorAll(

                    "option[data-department]"

                )

            ).map(

                function(option) {

                    return option.cloneNode(

                        true

                    );

                }

            );

        // =====================================================

        // FILTER HOD

        // =====================================================

        function filterHods() {

            const selectedDepartment =

                department.value;

            hodSelect.innerHTML =

                "";

            const defaultOption =

                document.createElement(

                    "option"

                );

            defaultOption.value =

                "";

            if (!selectedDepartment) {

                defaultOption.textContent =

                    "Pilih Jabatan Terlebih Dahulu";

                hodSelect.appendChild(

                    defaultOption

                );

                hodSelect.disabled =

                    true;

                return;

            }

            defaultOption.textContent =

                "Tiada Ketua Unit / Belum Ditentukan";

            hodSelect.appendChild(

                defaultOption

            );

            let found =

                false;

            allHodOptions.forEach(

                function(option) {

                    if (

                        option.dataset.department ===

                        selectedDepartment

                    ) {

                        hodSelect.appendChild(

                            option.cloneNode(true)

                        );

                        found =

                            true;

                    }

                }

            );

            /*

             * HOD OPTIONAL:

             * keep enabled even if none found.

             */

            hodSelect.disabled =

                false;

            if (!found) {

                defaultOption.textContent =

                    "Tiada Ketua Unit untuk jabatan ini";

            }

            const previousHodId =

                "<%= h(formHodId) %>";

            if (previousHodId) {

                const previousOption =

                    hodSelect.querySelector(

                        'option[value="'

                        +

                        previousHodId

                        +

                        '"]'

                    );

                if (previousOption) {

                    hodSelect.value =

                        previousHodId;

                }

            }

        }

        department.addEventListener(

            "change",

            filterHods

        );

        filterHods();

        // =====================================================

        // PASSWORD TOGGLE

        // =====================================================

        document

            .querySelectorAll(

                ".password-toggle"

            )

            .forEach(

                function(button) {

                    button.addEventListener(

                        "click",

                        function() {

                            const target =

                                document.getElementById(

                                    this.dataset.target

                                );

                            if (

                                target.type ===

                                "password"

                            ) {

                                target.type =

                                    "text";

                                this.textContent =

                                    "Sembunyi";

                            } else {

                                target.type =

                                    "password";

                                this.textContent =

                                    "Lihat";

                            }

                        }

                    );

                }

            );

        // =====================================================

        // FORM VALIDATION

        // =====================================================

        registerForm.addEventListener(

            "submit",

            function(event) {

                if (

                    password.value.length < 6

                ) {

                    event.preventDefault();

                    alert(

                        "Kata laluan mestilah mempunyai sekurang-kurangnya 6 aksara."

                    );

                    password.focus();

                    return;

                }

                if (

                    password.value !==

                    confirmPassword.value

                ) {

                    event.preventDefault();

                    alert(

                        "Kata laluan dan pengesahan kata laluan tidak sepadan."

                    );

                    confirmPassword.focus();

                    return;

                }

                if (

                    !department.value

                ) {

                    event.preventDefault();

                    alert(

                        "Sila pilih jabatan."

                    );

                    department.focus();

                    return;

                }

                /*

                 * Ketua Unit is OPTIONAL.

                 * No validation for empty hodId.

                 */

                registerButton.disabled =

                    true;

                registerButton.textContent =

                    "Mendaftar...";

            }

        );

    }

);

</script>

</body>

</html>
