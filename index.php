<?php
$yourname = "Tung Blog!";
$yourstudentnumber = "A123456789";
$image="tung.jpg"; // this must be included and uploaded as yourpic.jpg in your docker image (Dockerfile)
$uname=php_uname();
$all_your_output = <<<HTML
<html>
<head>
<meta charset="utf-8"/>
<title>$yourname - $yourstudentnumber</title>
</head>
<body>
<h1>$yourname - $yourstudentnumber</h1>
<img src="/$image">
<div>$uname</div>
</body>
<html>
HTML;
echo $all_your_output;
?>
