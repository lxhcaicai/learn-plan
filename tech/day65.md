## SQL 练习

### [1. 查询所有列](https://www.nowcoder.com/practice/f9f82607cac44099a77154a80266234a?tpId=199&tqId=1971219&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```sql
select * from user_profile
```

```sql
select id, device_id, gender, age, university, province from user_profile
```

### [2.查询多列](https://www.nowcoder.com/practice/499b6d01eae342b2aaeaf4d0da61cab0?tpId=199&tqId=1971218&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```sql
select device_id, gender, age, university from user_profile
```

### [3.查询结果去重](https://www.nowcoder.com/practice/82ebd89f12cf48efba0fecb392e193dd?tpId=199&tags=&title=&difficulty=0&judgeStatus=0&rp=0&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%E7%AF%87%26topicId%3D199)

distinct 关键字

```sql
select distinct university from user_profile
```

group 分组

```sql
select university from user_profile group by university
```

### [4.查询结果限制返回行数](https://www.nowcoder.com/practice/c7ad0e2df4f647dfa5278e99894a7561?tpId=199&tqId=1971238&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

 **使用LIMIT限制结果集**

LIMIT 子句可以被用于强制 SELECT 语句返回指定的记录数。
LIMIT 接受一个或两个数字参数。参数必须是一个整数常量。
如果只给定一个参数，它表示返回最大的记录行数目。
如果给定两个参数，第一个参数指定第一个返回记录行的偏移量，第二个参数指定返回记录行的最大数目。

``` sql
select device_id from user_profile order by id limit 2
```

### [5.将查询后的列重新命名](https://www.nowcoder.com/practice/0d8f49aeaf7a4e1cb7fecec980712113?tpId=199&tqId=1971243&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

``` sql
select device_id user_infos_example from user_profile limit 2
```

### [6.查找后排序](https://www.nowcoder.com/practice/cd4c5f3a64b4411eb4810e28afed6f54?tpId=199&tqId=2002632&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

升序（ASC）或降序（DESC）

```sql
select device_id, age from user_profile order by age asc
```

### [7.查找后多列排序](https://www.nowcoder.com/practice/39f74706f8d94d37865a82ffb7ba67d3?tpId=199&tqId=2002633&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```sql
select device_id, gpa, age from user_profile order by gpa asc, age asc
```

### [8.查找后降序排列](https://www.nowcoder.com/practice/d023ae0191e0414ca1b19451099a39f1?tpId=199&tqId=2002634&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```sql
select device_id, gpa, age from user_profile order by gpa desc, age desc
```

### [9. 查找学校是北大的学生信息](https://www.nowcoder.com/practice/7858f3e234bc4d85b81b9a6c3926f49f?tpId=199&tqId=1971248&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```sql
select device_id, university from user_profile where university = '北京大学'
```

### [10. 查找年龄大于24岁的用户信息](https://www.nowcoder.com/practice/2ae16bf2fd54415f99344e6024470d57?tpId=199&tqId=1971384&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```sql
select device_id, gender, age, university from user_profile where age >= 24
```

