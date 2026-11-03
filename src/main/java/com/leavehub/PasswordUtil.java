package com.leavehub;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;


/**
 * Utiliti kata laluan untuk sistem PKB.
 *
 * Nota:
 * SHA-256 digunakan untuk pembangunan semasa.
 * Untuk production, gunakan algoritma password hashing
 * seperti BCrypt atau Argon2.
 */
public final class PasswordUtil {


    // =========================================================
    // PREVENT OBJECT CREATION
    // =========================================================

    private PasswordUtil() {
    }



    // =========================================================
    // HASH PASSWORD
    // =========================================================

    public static String hash(String value) {


        if (value == null) {

            throw new IllegalArgumentException(
                "Kata laluan tidak boleh null."
            );
        }


        try {


            MessageDigest md =
                    MessageDigest.getInstance(
                        "SHA-256"
                    );


            byte[] bytes =
                    md.digest(
                        value.getBytes(
                            StandardCharsets.UTF_8
                        )
                    );


            StringBuilder result =
                    new StringBuilder(
                        bytes.length * 2
                    );


            for (byte b : bytes) {

                result.append(
                    String.format(
                        "%02x",
                        b & 0xff
                    )
                );
            }


            return result.toString();


        } catch (NoSuchAlgorithmException e) {

            throw new IllegalStateException(
                "Algoritma SHA-256 tidak tersedia.",
                e
            );
        }
    }
}