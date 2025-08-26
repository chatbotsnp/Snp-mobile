final inter = ta.intersection(tb).length.toDouble();
    final denom = (ta.length + tb.length - inter).toDouble();
    final jaccard = denom == 0 ? 0 : inter / denom;

    // bonus nếu từ khoá đầu/đuôi trùng
    final wordsA = a.split(' ');
    final wordsB = b.split(' ');
    final headBonus = (wordsA.isNotEmpty && wordsB.isNotEmpty && wordsA.first == wordsB.first) ? 0.05 : 0.0;
    final tailBonus = (wordsA.isNotEmpty && wordsB.isNotEmpty && wordsA.last == wordsB.last) ? 0.05 : 0.0;

    return (jaccard + headBonus + tailBonus).clamp(0.0, 1.0);
  }

  /// Bỏ dấu tiếng Việt (bản rút gọn đủ tốt cho demo)
  String _removeDiacritics(String str) {
    const src = 'àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệ'
        'ìíỉĩịòóỏõọôồốổỗộơờớởỡợ'
        'ùúủũụưừứửữựỳýỷỹỵđ'
        'ÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬÈÉẺẼẸÊỀẾỂỄỆ'
        'ÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢ'
        'ÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴĐ';
    const dst = 'aaaaaaaaaaaaaaaaaeeeeeeeeeee'
        'iiiiiooooooooooooooo'
        'uuuuuuuuuu yyyyyd'
        'AAAAAAAAAAAAAAAAAEEEEEEEEEEE'
        'IIIII OOOOOOOOOOOOO'
        'UUUUUUUUUU YYYYYD';

    final map = <String, String>{};
    for (int i = 0; i < src.length; i++) {
      map[src[i]] = dst[i];
    }
    final sb = StringBuffer();
    for (final ch in str.split('')) {
      sb.write(map[ch] ?? ch);
    }
    return sb.toString().replaceAll('  ', ' ').trim();
  }
}
