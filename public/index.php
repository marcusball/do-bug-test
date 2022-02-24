<?php

$length = $_GET['length'] ?: 6969;
$str = $_GET['char'] ?: 'A';

if (!is_int($length) && !ctype_digit($length)) {
    die('invalid length');
}

echo str_repeat($str, $length);
