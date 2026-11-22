<%@ page contentType="text/html;charset=UTF-8" %>

<%
    if (session.getAttribute("userId") == null) {

        response.sendRedirect(
            request.getContextPath() + "/"
        );

        return;
    }

    String name =
        (String) session.getAttribute("userName");

    if (
        name == null ||
        name.isBlank()
    ) {
        name = "Pengguna";
    }
%>

<!DOCTYPE html>

<html lang="ms">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>Tukar Kata Laluan - PKB</title>

    <link
        rel="stylesheet"
        href="<%= request.getContextPath() %>/css/style.css?v=20260914-unified"
    >

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

        .brand { margin-bottom: 18px; text-align: center; }
        .login-logo { width: 145px; max-width: 55%; height: auto; object-fit: contain; }

        .login-card h1 {
            margin: 0 0 8px;
            color: #172033;
            text-align: center;
            font-size: 23px;
            line-height: 1.25;
            font-weight: 700;
        }

        .password-intro {
            margin: 0 0 20px;
            color: #8791a2;
            text-align: center;
            font-size: 12.5px;
            line-height: 1.55;
        }

        .error-message {
            margin-bottom: 14px;
            padding: 10px 12px;
            border: 1px solid #efcdd2;
            border-radius: 9px;
            background: #fff0f2;
            color: #a72d39;
            font-size: 12px;
            line-height: 1.5;
        }

        .password-form { display: flex; flex-direction: column; }
        .form-group { margin-bottom: 14px; }
        .form-group label {
            display: block;
            margin-bottom: 6px;
            color: #3f495b;
            font-size: 12.5px;
            line-height: 1.35;
            font-weight: 600;
        }

        .form-group input {
            width: 100%;
            height: 42px;
            padding: 0 13px;
            border: 1px solid #dfe3e9;
            border-radius: 9px;
            background: #fff;
            color: #333d50;
            font: 400 12.5px "Segoe UI", Arial, sans-serif;
            outline: none;
        }

        .form-group input:focus {
            border-color: #a84754;
            box-shadow: 0 0 0 3px rgba(141,31,45,.08);
        }

        .password-visibility {
            display: flex;
            align-items: center;
            gap: 8px;
            margin: 0 0 17px;
            color: #687284;
            font-size: 12px;
            cursor: pointer;
        }

        .password-visibility input { width: 15px; height: 15px; margin: 0; accent-color: #8d1f2d; }

        .password-submit {
            width: 100%;
            min-height: 42px;
            padding: 10px 14px;
            border: 1px solid #8d1f2d;
            border-radius: 9px;
            background: linear-gradient(135deg,#8d1f2d,#a72a3b);
            color: #fff;
            font: 600 12.5px "Segoe UI", Arial, sans-serif;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(141,31,45,.16);
        }

        .password-submit:hover:not(:disabled) { background: linear-gradient(135deg,#701722,#8d1f2d); }
        .password-submit:disabled { opacity: .7; cursor: not-allowed; }

        @media (max-width: 520px) {
            body.login-page { padding: 14px 10px; }
            .login-card { padding: 26px 22px 23px; border-radius: 15px; }
            .login-logo { width: 132px; }
        }
    </style>

</head>


<body class="login-page">


<div class="login-card">


    <!-- =====================================================
         LOGO PKB
         ===================================================== -->

    <div class="brand">

        <img
            src="<%= request.getContextPath() %>/images/logo-pkb.png"
            alt="Permodalan Kedah Berhad"
            class="login-logo"
        >

    </div>



    <!-- =====================================================
         TAJUK
         ===================================================== -->

    <h1>Cipta Kata Laluan Baharu</h1>

    <p class="password-intro">
        Kata laluan yang diberikan oleh pentadbir
        adalah sementara.
        Sila cipta kata laluan baharu sebelum meneruskan penggunaan sistem.
    </p>



    <!-- =====================================================
         ERROR
         ===================================================== -->

    <% if ("1".equals(request.getParameter("error"))) { %>

        <div class="error-message">
            Kata laluan mestilah sama dan mempunyai sekurang-kurangnya 6 aksara.
        </div>

    <% } %>



    <!-- =====================================================
         FORM
         ===================================================== -->

    <form
        method="post"
        action="<%= request.getContextPath() %>/change-password"
        id="passwordForm"
        class="password-form"
    >


        <!-- KATA LALUAN BARU -->

        <div class="form-group">
            <label for="newPassword">Kata Laluan Baharu</label>
            <input
                type="password"
                name="newPassword"
                id="newPassword"
                minlength="6"
                maxlength="100"
                autocomplete="new-password"
                required
            >
        </div>



        <!-- SAHKAN KATA LALUAN -->

        <div class="form-group">
            <label for="confirmPassword">Sahkan Kata Laluan Baharu</label>
            <input
                type="password"
                name="confirmPassword"
                id="confirmPassword"
                minlength="6"
                maxlength="100"
                autocomplete="new-password"
                required
            >
        </div>



        <!-- SHOW PASSWORD -->

        <label class="password-visibility">
            <input type="checkbox" id="showPassword">
            Paparkan kata laluan
        </label>



        <!-- BUTTON -->

        <button
            type="submit"
            class="password-submit"
            id="submitButton"
        >
            Simpan Kata Laluan Baharu
        </button>


    </form>


</div>



<script>

    // =========================================================
    // PAPARKAN / SEMBUNYIKAN KATA LALUAN
    // =========================================================

    const showPassword =
        document.getElementById(
            "showPassword"
        );

    const newPassword =
        document.getElementById(
            "newPassword"
        );

    const confirmPassword =
        document.getElementById(
            "confirmPassword"
        );


    showPassword.addEventListener(
        "change",
        function () {

            const type =
                this.checked
                    ? "text"
                    : "password";


            newPassword.type =
                type;

            confirmPassword.type =
                type;
        }
    );



    // =========================================================
    // VALIDATION
    // =========================================================

    document
        .getElementById(
            "passwordForm"
        )
        .addEventListener(
            "submit",
            function (event) {

                if (
                    newPassword.value !==
                    confirmPassword.value
                ) {

                    event.preventDefault();

                    alert(
                        "Kata laluan baharu dan pengesahan kata laluan tidak sepadan."
                    );

                    confirmPassword.focus();

                    return;
                }


                if (
                    newPassword.value.length < 6
                ) {

                    event.preventDefault();

                    alert(
                        "Kata laluan mestilah mempunyai sekurang-kurangnya 6 aksara."
                    );

                    newPassword.focus();

                    return;
                }


                const submitButton =
                    document.getElementById(
                        "submitButton"
                    );


                submitButton.disabled =
                    true;

                submitButton.textContent =
                    "Menyimpan...";
            }
        );

</script>


</body>

</html>
