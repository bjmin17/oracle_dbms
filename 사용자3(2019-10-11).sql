-- 여기는 USER3 화면입니다.
-- 현재 USER3 사용자가 사용할 수 있는 Table목록
SELECT * FROM TAB;

-- TABLE과 View의 차이
/*
---------------------------------------------------------------------
TABLE                  VIEW
---------------------------------------------------------------------
실제 저장된 데이터      가상의 데이터
                        테이블로부터 SELECT 실행한 후 보여주는 형태
CRUD 모두 가능          READ 조회(SELECT)만 가능한 형태
원본데이터               TABLE로부터 새로 생성된 보기전용 데이터
---------------------------------------------------------------------
*/

-- 단순한 성적테이블 조회
SELECT * FROM tbl_score;

-- JOIN 이란
-- 단순 성적테이블 조회로는 구체적으로 학생의 이름이라든가 다른 정보를
-- 찾기가 매우 어렵다.
-- 학번과 연계된 학생테이블로부터 학생이름을 연결하고
-- 학과와 연계된 학과테이블로부터 학과이름을 연결하여
-- 마치 한 개의 데이터 Sheet(엑셀표현)처럼 보기 위한 SQL

-- 학생테이블
DESC tbl_student;

-- 현재 학생테이블에 학과 코드 칼럼이 있음에도
-- SQL의 편의성을 고려하여
-- 성적테이블에 학과 코드를 추가하여 관리를 했다 : tbl_score2
-- 이런 상황이 되면 자칫 잘못하여 tbl_score2 테이블에 등록된
-- 학과 코드가 실제 학생의 학과 코드가 아닌 값이 등록될 수 있다.
-- 이런 경우 데이터를 조회했을 때 실제 데이터와 차이가 있는 오류가 날 수 있다.

-- tbl_score 테이블과 tbl_student를 JOIN하고
-- 그 결과에서 학과코드를 기준으로 다시 tbl_dept와 JOIN을 수행하는 SQL

-- tbl_score와 tbl_student JOIN
SELECT *
FROM tbl_score SC
    LEFT JOIN tbl_student ST
        ON SC.s_num = ST.st_num;
        
SELECT * FROM tbl_dept;

-- 학생데이터 전체 삭제 매우 주의!!!!
DELETE FROM tbl_student;

SELECT * FROM tbl_student;

-- 학생테이블과 학과테이블을 JOIN
-- 보고자하는 칼럼만 리스트로 나열하고
-- 결과를 학번순으로 정렬하여 보기
SELECT ST.st_num, ST.st_name, ST.st_dept,
        DP.d_name, DP.d_pro
FROM tbl_student ST
    LEFT JOIN tbl_dept DP
        ON ST.st_dept = DP.d_num
ORDER BY ST.st_num;

-- 위의 SQL을 View로 생성
-- 1. ORDER BY 절을 삭제
-- 2. 각 칼럼에 별도의 Alias 설정하기
-- 3. SQL문을 () 감싸기
-- 4. CREATE VIEW AS 키워드 추가
CREATE VIEW view_st_dept
AS(
    SELECT ST.st_num 학번, 
            ST.st_name 이름,
            ST.st_dept 학과코드,
            DP.d_name 학과이름,
            DP.d_pro 담임교수
    FROM tbl_student ST
        LEFT JOIN tbl_dept DP
            ON ST.st_dept = DP.d_num
);

SELECT * FROM view_st_dept;

SELECT * FROM view_st_dept
WHERE 학과이름 = '컴퓨터공학';

SELECT * FROM view_st_dept
WHERE 학과이름 LIKE '컴퓨터%'
ORDER BY 학번;

-- view_st_dept를 사용해서
-- 학과별로 학생 수(COUNT)를 확인
SELECT 학과코드, 학과이름, COUNT(학과코드)
FROM view_st_dept
GROUP BY 학과코드, 학과이름
ORDER BY 학과이름 ; -- 003 경영학 26, 005 군사학 18, ,,,

-- 학생 수를 기준으로 오름차순 정렬
-- 집계함수(SUM, COUNT, MAX, MIN, AVG)를 사용할 때
-- 만약 집계함수로 감싸지 않은 칼럼을 Projection(SELECT 다음에 나열한 칼럼)에 표시하려고 하면
-- 그 칼럼들은 반드시 GROUP BY 절에 칼럼들을 나열해 주어야 한다.
SELECT 학과코드, 학과이름, COUNT(학과코드)
FROM view_st_dept
GROUP BY 학과코드, 학과이름 -- 학과코드가 같은 종류끼리 묶기
ORDER BY COUNT(학과코드); -- 002 영어영문 15, 005 군사학 18, ,,,
-- 1. 전체 데이터에서 학과코드 별로 묶어서, 학과 코드가 무엇인지 List
-- 2. List내에 포함된 학생 수를 계산하여 보기
-- >> 학과코드별 부분 합(개수)을 계산하기

-- 이 SQL에서는 학번은 현재 view에서 절대 중복된 값이 없으므로
-- GROUP BY가 아무런 효과를 발휘하지 못한다.
SELECT 학번, 이름, COUNT(*)
FROM view_st_dept
GROUP BY 학번, 이름;

-- 학과별로 학생 수를 계산을 하고
-- 학생 수가 20명 이상인 과만 보고 싶다.
-- 집계를 계산 후 결과에 대한 조건 설정
SELECT 학과코드, 학과이름, COUNT(*)
FROM view_st_dept
GROUP BY 학과코드, 학과이름
HAVING COUNT(*) >= 20 ; -- 003 경영학 26, 001 컴퓨터공학 22

-- 학과별로 학생 수를 계산을 하고
-- 컴퓨터공학 학과만 보여라
-- 4만명이라 할때 4만명 전체 data를 그룹화하고 -> List로 묶고 -> "컴퓨터공학"을 찾기때문에
-- 느림,, 특히 GROUP BY는 SELECT문 중에 제일 느림
SELECT 학과코드, 학과이름, COUNT(*)
FROM view_st_dept
GROUP BY 학과코드, 학과이름
HAVING 학과이름 = '컴퓨터공학'; -- 001 컴퓨터공학 22
-- HAVING절은 집계함수나 연산결과로 나온부분만 조건으로 달기
-- 칼럼으로 조건 달면 어리석은 짓
-- HAVING 절은 GROUP BY가 이루어지고, 집계함수가 계산된 후
-- 조건을 설정하여 리스트를 추출하는 부분
-- 이 경우 원본데이터를 먼저 GROUP 하는 연산이 수행되고
-- 그 결과에 대하여 조건을 설정한다.
-- 만약 어떤 기존의 칼럼을 기준으로 조건을 설정하려면 
-- HAVING 이 아닌 WHERE에서 조건을 설정하여
-- 추출되는 LIST 개수를 줄이고
-- 추출된 LIST만 가지고 GROUP, 집계함수 연산을 수행하는 것이
-- SQL 수행 효율면에서 매우 유리하다.

-- 리스트 관계없이 그 다음에 WHERE 컴퓨터공학만 추출하고, -> 학과코드와 학과이름 GROUP으로 묶음 -> COUNT 실행
SELECT 학과코드, 학과이름, COUNT(*)
FROM view_st_dept -- 1. 실행
WHERE 학과이름 = '컴퓨터공학' -- 2번 실행
GROUP BY 학과코드, 학과이름; -- 3번 실행-- 001 컴퓨터공학 22
-- WHERE에 의해 제한 LIST만 가지고 GROUP 실행

-- 성적테이블과 학생테이블 JOIN
SELECT *
FROM tbl_score SC
    LEFT JOIN tbl_student ST
        ON SC.s_num = ST.st_num;

CREATE VIEW view_sc_st
AS
(
    SELECT SC.s_num AS 학번, ST.st_name AS 이름,
            ST.st_dept AS 학과코드, SC.s_kor AS 국어, SC.s_eng AS 영어, SC.s_math AS 수학
    FROM tbl_score SC
        LEFT JOIN tbl_student ST
            ON SC.s_num = ST.st_num
);

SELECT * FROM view_sc_st;

-- 생성된 2개의 view JOIN
SELECT SC.학번, SC.이름, SC.학과코드, DP.학과이름, 
        SC.국어, SC.영어, SC.수학
FROM view_sc_st SC-- 주(main) table
    LEFT JOIN view_st_dept DP-- 보조(sub) table
        ON SC.학과코드 = DP.학과코드
ORDER BY SC.학번; -- 똑같은 data가 여러개씩 중복으로 나와서 문제

-- 2개의 view JOIN을 했더니 결과가 이상하게 생성되었다.
SELECT * 
FROM tbl_score SC
    LEFT JOIN tbl_student ST
        ON SC.s_num = ST.st_num 
    LEFT JOIN tbl_dept DP
        ON ST.st_dept = DP.d_num; -- 어제와는 다르게 SC가 아닌 참조한 ST와 DP를 연계

SELECT SC.s_num, ST.st_name, DP.d_name, DP.d_pro,
        SC.s_kor, SC.s_eng, SC.s_math
FROM tbl_score SC
    LEFT JOIN tbl_student ST
        ON SC.s_num = ST.st_num 
    LEFT JOIN tbl_dept DP
        ON ST.st_dept = DP.d_num;

DROP VIEW tbl_성적일람표; -- view는 alter가 없으니 삭제하고 다시 만들기
DROP VIEW view_성적일람표;
CREATE VIEW view_성적일람표
AS
(
    SELECT SC.s_num AS 학번, 
            ST.st_name AS 학생이름 , 
            ST.st_dept AS 학과코드, 
            DP.d_name AS 학과이름, 
            DP.d_pro AS 담임교수,
            SC.s_kor AS 국어,
            SC.s_eng AS 영어,
            SC.s_math AS 수학,
            SC.s_kor + SC.s_eng + SC.s_math AS 총점,
            ROUND((SC.s_kor + SC.s_eng + SC.s_math) / 3,0) AS 평균,
            RANK() OVER (ORDER BY (SC.s_kor + SC.s_eng + SC.s_math) DESC) AS 석차
    FROM tbl_score SC
        LEFT JOIN tbl_student ST
            ON SC.s_num = ST.st_num 
        LEFT JOIN tbl_dept DP
            ON ST.st_dept = DP.d_num
);

SELECT * FROM view_성적일람표;

-- 전체 학생의 과목별 총점
SELECT SUM(국어), SUM(영어), SUM(수학)
FROM view_성적일람표; -- 640 550 594

-- 학과별로 과목별 총점
SELECT 학과코드, 학과이름, SUM(국어), SUM(영어), SUM(수학)
FROM view_성적일람표
GROUP BY 학과코드, 학과이름;

SELECT 학과코드, 학과이름, 
        SUM(국어) AS 국어총점,
        SUM(영어) AS 영어총점,
        SUM(수학) AS 수학총점,
        SUM(총점) AS 전체총점,
        ROUND(AVG(평균),1) AS 전체평균
FROM view_성적일람표
GROUP BY 학과코드, 학과이름;

-- 경영학, 영어영문과 학생들의 성적일람표의 집계를 계산
SELECT 학과코드, 학과이름, 
        SUM(국어) AS 국어총점,
        SUM(영어) AS 영어총점,
        SUM(수학) AS 수학총점,
        SUM(총점) AS 전체총점,
        ROUND(AVG(평균),1) AS 전체평균
FROM view_성적일람표
WHERE 학과이름 IN ('영어영문', '경영학')
GROUP BY 학과코드, 학과이름; -- 영어영문과와 경영학만 표시

-- WHERE, HAVING으로 어떤 조건을 부여할 때는
-- 길이가 가변적인 값 조건으로 조회하기 보다는
-- 고정된 길이의 값 조건으로 조회하는 것이 결과를 더 확실하게 찾을 수 있다.
-- 학과이름으로 조건을 부여하는 것 보다는
-- 학과코드로 조건을 부여하는 것이 좋다.
SELECT 학과코드, 학과이름, 
        SUM(국어) AS 국어총점,
        SUM(영어) AS 영어총점,
        SUM(수학) AS 수학총점,
        SUM(총점) AS 전체총점,
        ROUND(AVG(평균),1) AS 전체평균
FROM view_성적일람표
WHERE 학과코드 IN ('002', '003')
GROUP BY 학과코드, 학과이름; -- WHERE를 학과이름이 아닌 학과코드로 하는게 좋음(정규화처럼)

-- DELETE tbl_score;

SELECT * FROM tbl_score;

-- 학과별 평균이 75점 이상인 학과만 표시
-- GROUP 묶고 집계를 수행한 결과를 조건으로 설정한 조회
SELECT 학과코드, 학과이름, 
        SUM(국어) AS 국어총점,
        SUM(영어) AS 영어총점,
        SUM(수학) AS 수학총점,
        SUM(총점) AS 전체총점,
        ROUND(AVG(평균),1) AS 전체평균
FROM view_성적일람표
GROUP BY 학과코드, 학과이름
HAVING ROUND(AVG(평균),1) >= 75;

-- 학과 코드가 002부터 004까지
-- 문자열이지만 데이터의 길이가 모두 같은 경우
-- 관계연산자 BETWEEN을 사용한 범위 조회가 가능하다.
SELECT 학과코드, 학과이름, 
        SUM(국어) AS 국어총점,
        SUM(영어) AS 영어총점,
        SUM(수학) AS 수학총점,
        SUM(총점) AS 전체총점,
        ROUND(AVG(평균),1) AS 전체평균
FROM view_성적일람표

WHERE 학과코드 BETWEEN '002' AND '004'
-- WHERE 학과코드가 >= '002' AND 학과코드 <= '005'

GROUP BY 학과코드, 학과이름
ORDER BY 학과코드;

-- view_성적일람표에 어떤 학과들이 있냐?
SELECT 학과코드, 학과이름
FROM view_성적일람표
GROUP BY 학과코드, 학과이름 ;

SELECT 학과코드, 학과이름,
        COUNT(*) 학생수,
        MAX(총점) AS 최고점,
        MIN(총점) AS 최저점,
        SUM(총점) AS 전체총점,
        ROUND(AVG(평균),1) AS 전체평균
FROM view_성적일람표
GROUP BY 학과코드, 학과이름 -- 단일코드에서는 누가 최고점, 최저점인지 찾기 어려움
ORDER BY 학과코드;

-- 통계 집계
-- SUB Query
-- UNION

-- 제약조건
-- 참조무결성 설정
-- 기존테이블에 제약조건을 추가
-- 이 정도까지 배우고 계속 연습할 계획