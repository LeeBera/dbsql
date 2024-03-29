SELECT *
FROM user_tab_comments
WHERE table_name = 'EMP';
--제약조건 활성화 /비활성화
--어떤 제약조건을 활성화(비활성화) 시킬 대상??

--emp fk제약 (dept테이블의 deptno컬럼 참조)
--FK_EMP_DEPT 비활성화

ALTER TABLE emp DISABLE CONSTRAINT fk_emp_dept;

--제약조건에 위배되는 데이터가 들어갈수 있지 않을까?
INSERT INTO emp (empno, ename, deptno)
VALUES (9999, 'brown', 80);

--fk_emp_dept활성화
ALTER TABLE emp ENABLE CONSTRAINT fk_emp_dept;

--제약조건에 위배되는 데이터 (소속 부서번호가 80번인 데이터)가 존재하여 
--제약조건 활성화 불가
DELETE emp
WHERE empno = 9999;

--다시 한 번 fk_emp_dept활성화
ALTER TABLE emp ENABLE CONSTRAINT fk_emp_dept;
COMMIT;

SELECT *
FROM emp;

--현재 계정에 존재하는 테이블 목록 view : USER_TABLES
--현재 계정에 존재하는 제약조건 view : USER_CONSTRAINTS
--현재 계정에 존재하는 제약조건의 컬럼 view : USER_CONS_COLUMNS

SELECT *
FROM USER_CONSTRAINTS
WHERE TABLE_NAME = 'CYCLE';

--fk_emp_dept
SELECT *
FROM USER_CONS_COLUMNS
WHERE CONSTRAINT_NAME = 'PK_CYCLE';

--테이블에 설정된 제약조건 조회 (VIEW 조인)
--테이블 명 / 제약조건 명 / 컬럼명 / 컬럼 포지션

SELECT a.table_name, a.constraint_name, b.column_name, b.position
FROM user_constraints a, user_cons_columns b
WHERE a.constraint_name = b.constraint_name
AND a.constraint_type = 'P' -- PRIMARY KEY만 조회
ORDER BY a.table_name, b.position;

--emp 테이블과 8가지 컬럼 주석달기
--

--테이블 

SELECT *
FROM user_tab_comments
WHERE table_name = 'EMP';

--emp 테이블 주석
COMMENT ON TABLE emp IS '사원';

--emp 테이블의 컬럼 주석
SELECT *
FROM user_col_comments
WHERE table_name = 'EMP';

--EMPNO ENAME JOB MGR HIREDATE SAL COMM DEPTNO
COMMENT ON COLUMN emp.empno IS '사원번호';
COMMENT ON COLUMN emp.ename IS '이름';
COMMENT ON COLUMN emp.job IS '담당업무';
COMMENT ON COLUMN emp.mgr IS '관리자 사번';
COMMENT ON COLUMN emp.hiredate IS '입사일자';
COMMENT ON COLUMN emp.sal IS '급여';
COMMENT ON COLUMN emp.comm IS '상여';
COMMENT ON COLUMN emp.deptno IS '소속부서번호';

--user_tab_comments, user_col_comments view를 이용하여 
--customer, product, cycle, daily 테이블과 컬럼의 주석 정보를 조회하는 쿼리를 작성하라

--customer 테이블의 컬럼 주석
SELECT t.table_name, t.table_type, t.COMMENTS tab_comment, c.COLUMN_NAME, c.COMMENTS col_comment 
FROM user_col_comments c, user_tab_comments t
WHERE c.table_name IN ('CUSTOMER', 'PRODUCT', 'CYCLE', 'DAILY')
AND t.TABLE_NAME = c.TABLE_NAME;

--VIEW 생성 (emp테이블에서 sal, comm 두개 컬럼을 제외한다.)
CREATE OR REPLACE VIEW v_emp AS 
SELECT empno, ename, job, mgr, hiredate, deptno
FROM emp;

--INLINE VIEW
SELECT *
FROM (SELECT empno, ename, job, mgr, hiredate, deptno FROM emp);

--VIEW( 위 인라인뷰와 동일하다.
SELECT *
FROM v_emp;

--조인된 쿼리 결과를 view로 생성 : v_emp_dept
--emp, dept : 부서명, 사원번호, 사원명, 담당업무, 입사일자
CREATE OR REPLACE VIEW v_emp_dept AS 
SELECT a.dname, b.empno, b.ename, b.job, b.hiredate
FROM dept a, emp b
WHERE a.deptno = b.deptno;

SELECT *
FROM v_emp_dept;

--VIEW 제거
DROP VIEW v_emp;

--VIEW를 구성하는 테이블의 데이터를 변경하면 VIEW에도 영향이 간다.
--dept 30 - SALES
SELECT *
FROM v_emp_dept;

--dept테이블의 SALES --> MARKET SALES
UPDATE dept SET dname = 'MARKET SALES'
WHERE deptno = 30;

SELECT * --이것만 바뀌는게 아니라
FROM dept;

SELECT * --얘도 바뀜 왜냐면 얘는 그냥 테이블이 새로 생성되는게 아니라 조회하는 것이기 때문이다.
FROM v_emp_dept;

ROLLBACK;

--HR 계정에게 v_emp_dept view 조회권한을 준다)
GRANT SELECT ON v_emp_dept to hr;

--SEQUENCE 생성 (게시글 번호 부여용 시퀀스)
CREATE SEQUENCE seq_post
INCREMENT BY 1
START WITH 1;


SELECT seq_post.nextval, seq_post.currval
FROM dual;


SELECT seq_post.currval
FROM DUAL;

SELECT *
FROM post
WHERE reg_id = 'Brown'
AND title = '하하하하 재미있다.'
AND reg_dt = TO_DATE('2019//11/14 15:40:15', 'YYYY/MM/DD HH24:MI:SS');

SELECT *
FROM post
WHERE reg_id = 'Brown'
AND title = '하하하하 재미있다.'
AND reg_dt = TO_DATE('2019//11/14 15:40:15', 'YYYY/MM/DD HH24:MI:SS');

SELECT *
FROM post
WHERE post_id = 1;

--index
--rowid : 테이블 행의 물리적 주소, 해당 주소를 알면 빠르게 테이블에 접근하는 것이 가능하다.

SELECT product.*, ROWID
FROM product
WHERE ROWID = 'AAAFTEAAFAAAAFLAAA';

--table : pid, pnm
--pk_product : pid
SELECT pid
FROM product
WHERE ROWID = 'AAAFTEAAFAAAAFLAAA';


--시퀀스 복습
--시퀀스 : 중복되지 않은 정수 값을 리턴 해주는 객체
--1, 2, 3, .........

DESC emp_test;
DROP TABLE emp_test;
CREATE TABLE emp_test (
    empno NUMBER(4) PRIMARY KEY,
    ename VARCHAR2(15)
);

--INSERT INTO emp_test VALUE (중복되지 않는 값, 'brown');

--시퀀스 생성
CREATE SEQUENCE seq_emp_test;

INSERT INTO emp_test VALUES (seq_emp_test.nextval, 'brown');

SELECT *
FROM emp_test;

--얘는 ROLLBACK 불가
SELECT seq_emp_test.nextval
FROM dual;
ROLLBACK;

--실행계획을 통한 인덱스 사용여부 확인;
--emp 테이블에 empno컬럼을 기준으로 인덱스가 없을 때
ALTER TABLE emp DROP CONSTRAINT pk_emp;

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno =7369;

--인덱스가 없기 때문에 empno=7369인 데이터를 찾기 위해
--emp 테이블 전체를 찾아봐야 한다. => TABLE FULL SCAN

SELECT *
FROM TABLE(dbms_xplan.display);

Plan hash value: 3956160932
 
--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    37 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMP  |     1 |    37 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------
 --1번부터 읽고 0번을 읽는다
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("EMPNO"=7369)