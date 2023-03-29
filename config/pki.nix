{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.pki {
  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIElzCCAv+gAwIBAgIBATANBgkqhkiG9w0BAQsFADA6MRgwFgYDVQQKDA9GT09T
      VEVSLk5FVFdPUksxHjAcBgNVBAMMFUNlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0y
      MDA3MzExNjUxMjNaFw00MDA3MzExNjUxMjNaMDoxGDAWBgNVBAoMD0ZPT1NURVIu
      TkVUV09SSzEeMBwGA1UEAwwVQ2VydGlmaWNhdGUgQXV0aG9yaXR5MIIBojANBgkq
      hkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA44Twlu/kugD/99g6Oal69sj44xjjXTlk
      kTbAaNo1KpCmtwmlfvoUQ9A/GPN7r0bAxRYgg4lf0URzP9Ejj8rhc6ufKZp9cNIJ
      IyMllHYsm4n1VpFqq+OnU53bR1r/cfc3u1af+6DBqHVEniylRFCXpP548mN63fG2
      cMxqzCeNpzAcGhVJwt0xINLsKJldbqbg0Ay3OuRzzOqyIN90tuDvnjNS2rUsmekm
      7roxPNdE8Wjd6F7XNzxLqjlBuoKKGSa3sPE+gKXbMFoqegUI2kJExUxJdyvbTw4l
      bHmu9wlfGQsLb1qr3hl0qVzbbpSJUJ/75hQsbZ81Ennl1GNUMEKz+NXqaUkd2gqZ
      GOWtiiFsbzYte5LqZ5//LKpOfV3AEpStDhmSIOOY/Z7W6bpd6mxARFrHbnEfpDPb
      sd2E13+A90R3Q7FAr5RElWAsd1ezmGgRQn75tIq226vnxqtVCA3zDoFDuuFh0NA/
      iPqZuBs9kgN08m/qW8y+Xd0mWjfpqtjdAgMBAAGjgacwgaQwHwYDVR0jBBgwFoAU
      2lDSbYOdzwWLGe8eCpUhOlcCpOIwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8E
      BAMCAcYwHQYDVR0OBBYEFNpQ0m2Dnc8FixnvHgqVITpXAqTiMEEGCCsGAQUFBwEB
      BDUwMzAxBggrBgEFBQcwAYYlaHR0cDovL2lwYS1jYS5mb29zdGVyLm5ldHdvcmsv
      Y2Evb2NzcDANBgkqhkiG9w0BAQsFAAOCAYEAcbLRAckeh8EpDAuZXbqu6hsYO7+y
      A6Odu4fUTvfst/lrDyG0r8o+7Y7Un0bPFXlMenayeq20B8laCi68mXS/da2p7Ajx
      LVnQo6xV8g5Mkc6YZ0erS6jU0eFVoXuV1ZqCiLAiY4beZvq6OtTdoXsxykzhj5vH
      xIS/KkSy46PK7DiaaL+2iYVX8uoPOwr90IcbJG+ZyKDxS16nAvKtBYnazigUjNsx
      txXNkYVb++kVhCpZQbcdB1rGZTphCNFqR1gKXo5fv+OlyywQxvlR46g6dr4qCi+D
      Co+yMFgc3tkTxg3imeH8vo9EWTaJugIRbqbkWvqKBLXqowHDjSMQf/8J4W/oJawk
      LvurI17UfPDTR9b0YpwNkIWfEfes80ngdjDLstEwh+nPtppMFHO8z0W2IgY72iaQ
      25dAhsdlIfpGxGha7Z4r3TFh/xpxdGUJAU8o2NnirVPhwFNdCsTtskgbbIWo/pfk
      WHSTeNkgtTUWb3IYwqSMq8SITttXp/ig3Ibr
      -----END CERTIFICATE-----
    ''
  ];
}
