package com.gdu.test.config;

import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.SqlSessionTemplate;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.transaction.TransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

@EnableTransactionManagement                    // @Transactional 허용
@EnableScheduling                               // @Scheduled 허용
@MapperScan(basePackages="com.gdu.test.dao")  // @Mapper를 찾을 패키지
@PropertySource(value="classpath:application.yml")
@Configuration
public class DBConfig {

  @Autowired
  private Environment env;

    // HikariConfig : HikariCP¸¦ ÀÌ¿ëÇØ DB¿¡ Á¢¼ÓÇÒ ¶§ ÇÊ¿äÇÑ Á¤º¸¸¦ Ã³¸®ÇÏ´Â Hikari Å¬·¡½º
    @Bean
    HikariConfig hikariConfig() {
    HikariConfig hikariConfig = new HikariConfig();
    hikariConfig.setDriverClassName(env.getProperty("spring.datasource.hikari.driver-class-name"));
    hikariConfig.setJdbcUrl(env.getProperty("spring.datasource.hikari.jdbc-url"));
    hikariConfig.setUsername(env.getProperty("spring.datasource.hikari.username"));
    hikariConfig.setPassword(env.getProperty("spring.datasource.hikari.password"));
    return hikariConfig;
  }

    // HikariDataSource : CP(Connection Pool)À» Ã³¸®ÇÏ´Â Hikari Å¬·¡½º
    @Bean
    HikariDataSource hikariDataSource() {
    return new HikariDataSource(hikariConfig());
  }

    // SqlSessionFactory : SqlSessionTemplateÀ» ¸¸µé±â À§ÇÑ mybatis ÀÎÅÍÆäÀÌ½º
    @Bean
    SqlSessionFactory sqlSessionFactory() throws Exception {
    SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
    sqlSessionFactoryBean.setDataSource(hikariDataSource());
    sqlSessionFactoryBean.setConfigLocation(new PathMatchingResourcePatternResolver().getResource(env.getProperty("mybatis.config-location")));
    sqlSessionFactoryBean.setMapperLocations(new PathMatchingResourcePatternResolver().getResources(env.getProperty("mybatis.mapper-locations")));
    return sqlSessionFactoryBean.getObject();
  }

    // SqlSessionTemplate : Äõ¸® ½ÇÇàÀ» ´ã´çÇÏ´Â mybatis Å¬·¡½º
    @Bean
    SqlSessionTemplate sqlSessionTemplate() throws Exception {
    return new SqlSessionTemplate(sqlSessionFactory());
  }

    // TransactionManager : Æ®·£Àè¼ÇÀ» Ã³¸®ÇÏ´Â ½ºÇÁ¸µ ÀÎÅÍÆäÀÌ½º
    @Bean
    TransactionManager transactionManager() {
    return new DataSourceTransactionManager(hikariDataSource());
  }
  
}