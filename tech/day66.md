## SQL 练习

### [1. 查找某个年龄段的用户信息](https://www.nowcoder.com/practice/be54223075cc43ceb20e4ce8a8e3e340?tpId=199&tqId=1971603&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```go
select device_id, gender, age from user_profile where age between 20 and 23
```



### [2.查找除复旦大学的用户信息](https://www.nowcoder.com/practice/c12a056497404d1ea782308a7b821f9c?tpId=199&tqId=1971604&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```go
select device_id, gender, age, university from user_profile where university not in ("复旦大学")
```

### [3.用where过滤空值练习](https://www.nowcoder.com/practice/08c9846a423540319eea4be44e339e35?tpId=199&tqId=1971605&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```go
select device_id, gender, age, university from user_profile where age is not NULL
```

```go
select device_id, gender, age, university from user_profile where age != ""
```



### [4.高级操作符练习(1)](https://www.nowcoder.com/practice/2d2e37474197488fbdf8f9206f66651c?tpId=199&tqId=1971781&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```go
select device_id, gender, age, university, gpa from user_profile where gpa > 3.5 && gender = 'male'
```

### [5.高级操作符练习(2）](https://www.nowcoder.com/practice/25bcf6924eff417d90c8988f55675122?tpId=199&tqId=1971821&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```go
select device_id, gender, age, university, gpa from user_profile where gpa > 3.7 or university = '北京大学'
```

### [6.Where in 和Not in](https://www.nowcoder.com/practice/0355033fc2244cdaa09b2bd6e794c762?tpId=199&tqId=1975665&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```go
select device_id, gender, age, university, gpa from user_profile where university in ('北京大学', '复旦大学', '山东大学') 
```

### [7.操作符混合运用](https://www.nowcoder.com/practice/d5ac4c878b63477fa5e5dfcb427d9102?tpId=199&tqId=1975666&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```go
select device_id, gender, age, university, gpa from user_profile where gpa > 3.5 and university = '山东大学' or gpa > 3.7 and university = '复旦大学'
```

### [8. 查看学校名称中含北京的用户](https://www.nowcoder.com/practice/95d9922b1e2a49de80daa491889969ee?tpId=199&tqId=1975667&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```go
select device_id, age, university from user_profile where university like '%北京%'
```

### [9.查找GPA最高值](https://www.nowcoder.com/practice/4e22fc5dbd16414fb2c7683557a84a4f?tpId=199&tqId=1975668&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

```go
select max(gpa) as gpa from user_profile where university = '复旦大学'
```

```
select gpa from user_profile where university = '复旦大学' order by gpa desc limit 1
```

### [10.计算男生人数以及平均GPA](https://www.nowcoder.com/practice/7d9a7b2d6b4241dbb5e5066d7549ca01?tpId=199&tqId=1975669&ru=/exam/oj&qru=/ta/sql-quick-study/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D199)

1. 浮点数的平均值可能小数点位数很多，按照示例保存一位小数，用round函数

```go
select count(gender) as male_num, round(avg(gpa), 1) as avg_gpa from user_profile where gender = "male"
```

