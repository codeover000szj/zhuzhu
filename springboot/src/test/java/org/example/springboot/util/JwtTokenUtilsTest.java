package org.example.springboot.util;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import org.example.springboot.config.JwtConfig;
import org.junit.jupiter.api.Test;
import org.springframework.boot.autoconfigure.AutoConfigurations;
import org.springframework.boot.autoconfigure.context.ConfigurationPropertiesAutoConfiguration;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;

import java.util.Date;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class JwtTokenUtilsTest {

    @Test
    void bindsExternalSecretAndPreservesTokenCompatibility() {
        String secret = UUID.randomUUID().toString() + UUID.randomUUID();
        new ApplicationContextRunner()
                .withConfiguration(AutoConfigurations.of(ConfigurationPropertiesAutoConfiguration.class))
                .withUserConfiguration(JwtConfig.class, JwtTokenUtils.class)
                .withPropertyValues("jwt.secret=" + secret)
                .run(context -> {
                    assertNull(context.getStartupFailure());
                    assertEquals(secret, context.getBean(JwtConfig.class).getSecret());

                    String token = JwtTokenUtils.generateToken(7L, "demo-user", "USER");
                    assertEquals(7L, JWT.require(Algorithm.HMAC256(secret))
                            .withIssuer("drone-management-system").build()
                            .verify(token).getClaim("userId").asLong());

                    String existingToken = JWT.create().withClaim("userId", 9L)
                            .withIssuer("drone-management-system")
                            .withExpiresAt(new Date(System.currentTimeMillis() + 60000))
                            .sign(Algorithm.HMAC256(secret));
                    assertEquals(9L, JwtTokenUtils.verifyToken(existingToken)
                            .getClaim("userId").asLong());
                });
    }

    @Test
    void rejectsMissingOrBlankSecret() {
        JwtConfig config = new JwtConfig();
        assertNull(config.getSecret());
        assertThrows(IllegalArgumentException.class, () -> new JwtTokenUtils(config));
        config.setSecret("   ");
        assertThrows(IllegalArgumentException.class, () -> new JwtTokenUtils(config));
    }
}
