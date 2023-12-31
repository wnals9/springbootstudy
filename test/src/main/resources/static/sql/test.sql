-- 업로드 게시판 쿼리 테스트

-- 1. 업로드 목록 (업로드 - 첨부 조인, 업로드 - 사용자 조인)
--    첨부가 없는 업로드 게시글도 조회할 수 있도록 외부 조인을 사용함
--    작성자가 없는 업로드 게시글도 조회할 수 있도록 외부 조인을 사용함
SELECT UP.UPLOAD_NO, UP.TITLE, UP.CONTENTS, UP.CREATED_AT, UP.MODIFIED_AT, COUNT(ATC.ATTACH_NO) AS 첨부파일수, USR.USER_NO, USR.EMAIL, USR.NAME
  FROM UPLOAD_T UP LEFT OUTER JOIN ATTACH_T ATC
    ON UP.UPLOAD_NO = ATC.UPLOAD_NO LEFT OUTER JOIN USER_T USR
    ON UP.USER_NO = USR.USER_NO
 GROUP BY UP.UPLOAD_NO, UP.TITLE, UP.CONTENTS, UP.CREATED_AT, UP.MODIFIED_AT, USR.USER_NO, USR.EMAIL, USR.NAME;

-- 첨부 테이블 정보를 조회하지 않는다면 업로드 - 첨부의 조인을 제거하고 작업을 수행할 수 있음
SELECT A.UPLOAD_NO, A.TITLE, A.CONTENTS, A.CREATED_AT, A.MODIFIED_AT, A.ATTACH_COUNT, A.USER_NO, A.EMAIL, A.NAME
  FROM (SELECT ROW_NUMBER() OVER(ORDER BY UPLOAD_NO DESC) AS RN,
               UP.UPLOAD_NO, UP.TITLE, UP.CONTENTS, UP.CREATED_AT, UP.MODIFIED_AT,
               (SELECT COUNT(*) FROM ATTACH_T ATC WHERE UP.UPLOAD_NO = ATC.UPLOAD_NO) AS ATTACH_COUNT,
               USR.USER_NO, USR.EMAIL, USR.NAME
          FROM UPLOAD_T UP LEFT OUTER JOIN USER_T USR
            ON UP.USER_NO = USR.USER_NO) A
 WHERE A.RN BETWEEN 1 AND 9;









-- 블로그 쿼리 테스트

-- 1. 블로그 목록 (사용자 - 블로그 조인)

-- 부모 : 일대다 관계에서 일(PK, UNIQUE) - 사용자
-- 자식 : 일대다 관계에서 다(FK)         - 블로그

-- 내부 : 사용자와 블로그에 모두 존재하는 데이터를 조인하는 방식
-- 외부 : 사용자가 없는 블로그도 모두 조인하는 방식 (불가능)
--        블로그가 없는 사용자도 모두 조인하는 방식 (필요 없는 방식)

SELECT A.BLOG_NO, A.TITLE, A.CONTENTS, A.USER_NO, A.HIT, A.IP, A.CREATED_AT, A.MODIFIED_AT, A.EMAIL
  FROM (SELECT ROW_NUMBER() OVER(ORDER BY B.BLOG_NO DESC) AS RN, B.BLOG_NO, B.TITLE, B.CONTENTS, B.USER_NO, B.HIT, B.IP, B.CREATED_AT, B.MODIFIED_AT, U.EMAIL
          FROM USER_T U INNER JOIN BLOG_T B
            ON B.USER_NO = U.USER_NO) A
 WHERE A.RN BETWEEN 1 AND 10;

-- 2. 블로그 상세

-- 1) 조회수 증가
UPDATE BLOG_T
   SET HIT = HIT + 1
 WHERE BLOG_NO = 1;

-- 2) 블로그 상세 정보 조회
SELECT B.BLOG_NO, B.TITLE, B.CONTENTS, B.HIT, B.IP, B.CREATED_AT, B.MODIFIED_AT, U.USER_NO, U.EMAIL, U.NAME
  FROM USER_T U, BLOG_T B
 WHERE U.USER_NO = B.USER_NO
   AND B.BLOG_NO = 1;

-- 3) 댓글 목록
-- 블로그 - 댓글 : 1:N (댓글이 달린 블로그 정보는 이미 상세보기에 모두 표시되어 있으므로 여기에선 조인할 필요가 없음)
-- 사용자 - 댓글 : 1:N (댓글의 사용자 이름을 표시)
SELECT A.COMMENT_NO, A.CONTENTS, A.BLOG_NO, A.CREATED_AT, A.STATUS, A.DEPTH, A.GROUP_NO, A.USER_NO, A.NAME
  FROM (SELECT ROW_NUMBER() OVER(ORDER BY GROUP_NO DESC, DEPTH ASC, COMMENT_NO DESC) AS RN, C.COMMENT_NO, C.CONTENTS, C.BLOG_NO, C.CREATED_AT, C.STATUS, C.DEPTH, C.GROUP_NO, U.USER_NO, U.NAME
          FROM USER_T U INNER JOIN COMMENT_T C
            ON U.USER_NO = C.USER_NO
         WHERE C.BLOG_NO = 2) A
 WHERE A.RN BETWEEN 1 AND 10;



-- 계층 쿼리 테스트

-- 1. 목록 (??? 순으로 1 ~ 10)

-- 1) ROWNUM 가상 칼럼
SELECT FREE_NO, EMAIL, CONTENTS, CREATED_AT, STATUS, DEPTH, GROUP_NO, GROUP_ORDER
  FROM (SELECT ROWNUM AS RN, FREE_NO, EMAIL, CONTENTS, CREATED_AT, STATUS, DEPTH, GROUP_NO, GROUP_ORDER
          FROM (SELECT FREE_NO, EMAIL, CONTENTS, CREATED_AT, STATUS, DEPTH, GROUP_NO, GROUP_ORDER
                  FROM FREE_T
                 ORDER BY FREE_NO DESC))
 WHERE RN BETWEEN 1 AND 10;

-- 2) ROW_NUMBER() 함수
SELECT FREE_NO, EMAIL, CONTENTS, CREATED_AT, STATUS, DEPTH, GROUP_NO, GROUP_ORDER
  FROM (SELECT ROW_NUMBER() OVER(ORDER BY FREE_NO DESC) AS RN, FREE_NO, EMAIL, CONTENTS, CREATED_AT, STATUS, DEPTH, GROUP_NO, GROUP_ORDER
          FROM FREE_T)
 WHERE RN BETWEEN 1 AND 10;
 
 
-- 2. 검색

-- 1) 결과 개수
SELECT COUNT(*)
  FROM FREE_T
 WHERE EMAIL LIKE '%' || 'user1' || '%';

-- 2) 결과 목록
SELECT FREE_NO, EMAIL, CONTENTS, CREATED_AT, STATUS, DEPTH, GROUP_NO, GROUP_ORDER
  FROM (SELECT ROW_NUMBER() OVER(ORDER BY GROUP_NO DESC, GROUP_ORDER ASC) AS RN, FREE_NO, EMAIL, CONTENTS, CREATED_AT, STATUS, DEPTH, GROUP_NO, GROUP_ORDER
          FROM FREE_T
         WHERE EMAIL LIKE '%' || 'user1' || '%')
 WHERE RN BETWEEN 11 AND 20;



-- 사용자 쿼리 테스트

-- 1. 로그인 할 때(이메일, 비밀번호 입력)
-- 1) 정상 회원
SELECT USER_NO, EMAIL, PW, NAME, GENDER, MOBILE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, AGREE, PW_MODIFIED_AT, JOINED_AT
  FROM USER_T
 WHERE EMAIL = 'user1@naver.com'
   AND PW = '0FFE1ABD1A08215353C233D6E009613E95EEC4253832A761AF28FF37AC5A150C';

INSERT INTO ACCESS_T VALUES('user1@naver.com', SYSDATE);
COMMIT;

-- 2) 휴면 회원
SELECT USER_NO, EMAIL, PW, NAME, GENDER, MOBILE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, AGREE, PW_MODIFIED_AT, JOINED_AT
  FROM INACTIVE_USER_T
 WHERE EMAIL = 'user1@naver.com'
   AND PW = '0FFE1ABD1A08215353C233D6E009613E95EEC4253832A761AF28FF37AC5A150C';
-- 이후 휴면 복원으로 이동

-- 2. 이메일 중복 체크
SELECT EMAIL
  FROM USER_T
 WHERE EMAIL = 'user4@naver.com';

SELECT EMAIL
  FROM LEAVE_USER_T
 WHERE EMAIL = 'user4@naver.com';

SELECT EMAIL
  FROM INACTIVE_USER_T
 WHERE EMAIL = 'user4@naver.com';

-- 3. 휴면 처리 할 때 (12개월 이상 로그인 이력이 없다. 로그인 이력이 전혀 없는 사용자 중에서 가입일이 12개월 이상 지났다.)
INSERT INTO INACTIVE_USER_T
(
SELECT USER_NO, U.EMAIL, PW, NAME, GENDER, MOBILE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, AGREE, PW_MODIFIED_AT, JOINED_AT, SYSDATE
  FROM USER_T U LEFT OUTER JOIN ACCESS_T A
    ON U.EMAIL = A.EMAIL
 WHERE MONTHS_BETWEEN(SYSDATE, LOGIN_AT) >= 12
    OR (LOGIN_AT IS NULL AND MONTHS_BETWEEN(SYSDATE, JOINED_AT) >= 12)
);

DELETE
  FROM USER_T
 WHERE EMAIL IN(SELECT U.EMAIL
                  FROM USER_T U LEFT OUTER JOIN ACCESS_T A
                    ON U.EMAIL = A.EMAIL
                 WHERE MONTHS_BETWEEN(SYSDATE, LOGIN_AT) >= 12
                    OR (LOGIN_AT IS NULL AND MONTHS_BETWEEN(SYSDATE, JOINED_AT) >= 12));
COMMIT;

-- 4. 휴면 복원 할 때
INSERT INTO USER_T
(
SELECT USER_NO, EMAIL, PW, NAME, GENDER, MOBILE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, AGREE, PW_MODIFIED_AT, JOINED_AT
  FROM INACTIVE_USER_T
 WHERE EMAIL = 'user2@naver.com'
);

DELETE
  FROM INACTIVE_USER_T
 WHERE EMAIL = 'user2@naver.com';

SELECT USER_NO, EMAIL, PW, NAME, GENDER, MOBILE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, AGREE, PW_MODIFIED_AT, JOINED_AT
  FROM USER_T
 WHERE EMAIL = 'user2@naver.com';

INSERT INTO ACCESS_T VALUES('user2@naver.com', SYSDATE);
COMMIT;

-- 5. 탈퇴 할 때
INSERT INTO LEAVE_USER_T VALUES('user1@naver.com', TO_DATE('20220101', 'YYYYMMDD'), SYSDATE);
DELETE FROM USER_T WHERE USER_NO = 1;
COMMIT;
