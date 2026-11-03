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
/>

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

    <h1>
        Cipta Kata Laluan Baharu
    </h1>


    <p>

        Kata laluan yang diberikan oleh pentadbir
        adalah sementara.

        Sila cipta kata laluan baharu sebelum
        meneruskan penggunaan sistem.

    </p>



    <!-- =====================================================
         ERROR
         ===================================================== -->

    <% if ("1".equals(request.getParameter("error"))) { %>

        <div class="error">

            Kata laluan mestilah sama dan
            mempunyai sekurang-kurangnya
            6 aksara.

        </div>

    <% } %>



    <!-- =====================================================
         FORM
         ===================================================== -->

    <form
        method="post"
        action="<%= request.getContextPath() %>/change-password"
        id="passwordForm"
    >


        <!-- KATA LALUAN BARU -->

        <label for="newPassword">
            Kata Laluan Baharu
        </label>

        <input
            type="password"
            name="newPassword"
            id="newPassword"
            minlength="6"
            maxlength="100"
            autocomplete="new-password"
            required
        >



        <!-- SAHKAN KATA LALUAN -->

        <label for="confirmPassword">
            Sahkan Kata Laluan Baharu
        </label>

        <input
            type="password"
            name="confirmPassword"
            id="confirmPassword"
            minlength="6"
            maxlength="100"
            autocomplete="new-password"
            required
        >



        <!-- SHOW PASSWORD -->

        <div
            style="
                margin-top:10px;
                margin-bottom:18px;
            "
        >

            <label
                style="
                    display:flex;
                    align-items:center;
                    gap:8px;
                    font-size:13px;
                    cursor:pointer;
                "
            >

                <input
                    type="checkbox"
                    id="showPassword"
                    style="width:auto;"
                >

                Paparkan kata laluan

            </label>

        </div>



        <!-- BUTTON -->

        <button
            type="submit"
            class="btn primary wide"
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