## SQL 练习

### [1.分组计算练习题](https://www.nowcoder.com/practice/009d8067d2df47fea429afe2e7b9de45?tpId=199&tqId=1975670&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```sql
select 
    gender, university,
    count(device_id) as user_num,
    avg(active_days_within_30) as avg_active_days,
    avg(question_cnt) as avg_question_cnt
from user_profile
group by gender, university
```

### [2. 分组过滤练习题](https://www.nowcoder.com/practice/ddbcedcd9600403296038ee44a172f2d?tpId=199&tqId=1975671&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

- 表头重命名：as
- 用having不用where

```sql
select
    university,
    avg(question_cnt) as avg_question_cnt,
    avg(answer_cnt) as avg_answer_cnt
from user_profile
group by university
having avg_question_cnt < 5 or avg_answer_cnt < 20
```

### [3.分组排序练习题](https://www.nowcoder.com/practice/e00bbac732cb4b6bbc62a52b930cb15e?tpId=199&tqId=1975672&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```sql
select university,
    avg(question_cnt) as avg_question_cnt
from user_profile
group by university
order by avg_question_cnt

```

### [4. 浙江大学用户题目回答情况](https://www.nowcoder.com/practice/55f3d94c3f4d47b69833b335867c06c1?tpId=199&tqId=1975673&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```sql
select A.device_id, A.question_id, A.result 
from question_practice_detail as A
inner join user_profile as B
on B.device_id = A.device_id and B.university = '浙江大学'
```

```sql
select device_id, question_id, result
from question_practice_detail
where device_id in (
    select device_id from user_profile
    where university = '浙江大学'
)
order by question_id
```



### [5.统计每个学校的答过题的用户的平均答题数](https://www.nowcoder.com/practice/88aa923a9a674253b861a8fa56bac8e5?tpId=199&tqId=1975674&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```sql
select university,
    count(question_id) / count(distinct A.device_id) as avg_ansswer_cnt
from question_practice_detail as A 
inner join user_profile as B
on A.device_id = B.device_id
group by university
```

### [6.统计每个学校各难度的用户平均刷题数](https://www.nowcoder.com/practice/5400df085a034f88b2e17941ab338ee8?tpId=199&tqId=1975675&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```sql
select
    university,
    difficult_level,
    round(count(A.question_id) / count(distinct A.device_id), 4) as avg_answer_cnt
from question_practice_detail as A 

left join user_profile as B
on B.device_id = A.device_id

left join question_detail as C
on C.question_id = A.question_id
group by university, difficult_level
```

### [7. 统计每个用户的平均刷题数](https://www.nowcoder.com/practice/f4714f7529404679b7f8909c96299ac4?tpId=199&tqId=1975676&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```sql
select
    "山东大学" as university, difficult_level,
    count(A.question_id) / count(distinct A.device_id) as avg_answer_cnt
from question_practice_detail as A 

inner join user_profile as B
on B.device_id = A.device_id and B.university = '山东大学'

inner join question_detail as C
on C.question_id = A.question_id

group by difficult_level
```

### [8.  查找山东大学或者性别为男生的信息](https://www.nowcoder.com/practice/979b1a5a16d44afaba5191b22152f64a?tpId=199&tqId=1975677&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

- 不去重：union all

```sql
select 
    device_id, gender, age, gpa
from user_profile
where university = '山东大学'

union all

select 
    device_id, gender, age, gpa
from user_profile
where gender = 'male'
```

### [9.计算25岁以上和以下的用户数量](https://www.nowcoder.com/practice/30f9f470390a4a8a8dd3b8e1f8c7a9fa?tpId=199&tqId=1975678&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```go
select case when age < 25 or age is null then '25岁以下'
            when age >= 25 then '25岁及以上'
            end age_cut, count(*)number
from user_profile
group by age_cut
```

### [10.查看不同年龄段的用户明细](https://www.nowcoder.com/practice/ae44b2b78525417b8b2fc2075b557592?tpId=199&tqId=1975679&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```go
select device_id, gender,
    case
         when age >= 25 then '25岁及以上'
         when age >= 20 then '20-24岁'
         else '其他'
    end age_cut
from user_profile
    
```

