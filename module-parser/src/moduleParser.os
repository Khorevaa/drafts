/// Парсер модулей с 1С подобным синтаксисом.
/// @author ret-Phoenix
/// @version 0.0.0.1
/// @Module #lib.config

/// @param ИмяФайла - Строка - Путь к файлу с модулем
/// @return Строка - Если файл прочитан
Функция ПолучитьТекстИзФайла(ИмяФайла)
    ФайлОбмена = Новый Файл(ИмяФайла);
    Данные = "";
    Если ФайлОбмена.Существует() Тогда
        Текст = Новый ЧтениеТекста(ИмяФайла, КодировкаТекста.UTF8);
        Данные = Текст.Прочитать();
        Текст.Закрыть();
    Иначе
        ВызватьИсключение "Файл не найден: " + ИмяФайла;
    КонецЕсли;
    возврат Данные;
КонецФункции

/// Получает список методов модуля. Для каждого метода создается структура.
/// Структура модуля:
///   - Тип - Процедура / Функция
///   - Имя - Имя метода
///   - Описание - Описание метода
///   - Экспорт - Булево. Истина - экспортный, иначе приватный
///   - Параметры - ТаблицаЗначений параметров:
///     - Имя  
///     - ПоЗначению
///     - ЗначениеПоУмолчанию
///     - Описание
///   - ВозвращаемоеЗначение - Массив возможных возвращаемых значений
///
/// @param ИмяФайла - Строка - Путь к файлу с модулем
/// @return Массив - Массив с методами модуля.

Функция ПолучитьМетодыСОписанием(ИмяФайла) Экспорт
    
    Данные = ПолучитьТекстИзФайла(ИмяФайла);
    
    РегВыражение = Новый РегулярноеВыражение("(^\s*\/\/\/[^\/](.*)|^\s*(процедура|функция|procedure|function)\s+(.*)\(((.*)|(.*)\r\n(.*))\)\s+(.*))");
    РегВыражение.ИгнорироватьРегистр = Истина;
    РегВыражение.Многострочный = Истина;

    Совпадения = РегВыражение.НайтиСовпадения(Данные);
    МассивМетодов = Новый Массив;

    Документация = Новый Структура;
    ДокПараметры = Неопределено;
    ДокВозврат = Неопределено;
    ДокОписание = "";

    Для каждого Сп Из Совпадения Цикл

        СпГр = Сп.Группы;

        СтрДок = СокрЛП(СпГр[2].Значение);
// Сообщить(СтрДок);
        Если СтрДок <> ""  Тогда
            ПозицияТире = СтрНайти(СтрДок,"-");

            Если СтрНачинаетсяС(СтрДок,"@param") Тогда
                Если ДокПараметры = Неопределено Тогда
                    ДокПараметры = Новый Структура;
                КонецЕсли; Сообщить("66: " + СокрЛП(Сред(СтрДок, 7, ПозицияТире-1-7)));
                ДокПараметры.Вставить(СокрЛП(Сред(СтрДок, 7, ПозицияТире-1-7)), СокрЛП(Сред(СтрДок, ПозицияТире+1)));
            ИначеЕсли СтрНачинаетсяС(СтрДок,"@return") Тогда
                Если ДокВозврат = Неопределено Тогда
                    ДокВозврат = Новый Соответствие;
                КонецЕсли;
                ДокВозврат.Вставить(СокрЛП(Сред(СтрДок, 8, ПозицияТире-1-8)), СокрЛП(Сред(СтрДок, ПозицияТире+1)));
            ИначеЕсли СтрНачинаетсяС(СтрДок,"@Module") Тогда
                ДокПараметры = Неопределено;
                ДокВозврат = Неопределено;
                ДокОписание = "";
            Иначе
                ДокОписание  = ДокОписание  + Символы.ВК + Символы.ПС + СтрДок;
            КонецЕсли;

        Иначе
			
            Если СокрЛП(СпГр[4].Значение) = "" Тогда
                Продолжить;
            КонецЕсли;
            
            СтруктураМетода = Новый Структура;
            СтруктураМетода.Вставить("Тип", СокрЛП(СпГр[3].Значение));
            СтруктураМетода.Вставить("Имя", СокрЛП(СпГр[4].Значение));

            //# Перебор параметров
            СтрПараметры = СокрЛП(СпГр[5].Значение);

            ПараметрыМетода = Новый ТаблицаЗначений;
            ПараметрыМетода.Колонки.Добавить("Имя");
            ПараметрыМетода.Колонки.Добавить("ПоЗначению");
            ПараметрыМетода.Колонки.Добавить("ЗначениеПоУмолчанию");
            ПараметрыМетода.Колонки.Добавить("Описание");

            МассивПараметры = СтрРазделить(СтрПараметры,",", Ложь);

            Для каждого Элемент Из МассивПараметры Цикл
                Элемент = СокрЛП(Элемент);
                
                ПереданПоЗначению = Ложь;
                Если СтрНачинаетсяС(Элемент, "Знач ") Тогда
                    ПереданПоЗначению = Истина;
                    Элемент = Сред(Элемент,5);
                КонецЕсли;

                РегВыражениеЗначения = новый РегулярноеВыражение("(=|\s)(?=(?:[^\""]*\""[^\""]*\"")*(?![^\""]*\""))");
                
                РегВыражениеЗамены = новый РегулярноеВыражение("(\s)(?=(?:[^\""]*\""[^\""]*\"")*(?![^\""]*\""))");
                Элемент = РегВыражениеЗамены.Заменить(Элемент,"");

                СтруктураПараметра = РегВыражениеЗначения.Разделить(Элемент);

                СтрокаТЗ = ПараметрыМетода.Добавить();
                СтрокаТЗ.Имя = СтруктураПараметра[0];
                СтрокаТЗ.ПоЗначению = ПереданПоЗначению;
                Если СтруктураПараметра.Количество() >1 Тогда
                    СтрокаТЗ.ЗначениеПоУмолчанию  = СтруктураПараметра[2];
                КонецЕсли;

                Если ДокПараметры <> Неопределено Тогда
                    Если ДокПараметры.Свойство(СтрокаТЗ.Имя) Тогда
                        СтрокаТЗ.Описание = ДокПараметры[СтрокаТЗ.Имя];
                    КонецЕсли;
                КонецЕсли;

            КонецЦикла;

            СтрокаОригинал = СокрЛП(СпГр[0].Значение);
            РегВыражение = Новый РегулярноеВыражение("\s+(Экспорт)($|\s+|\/\/)");
            РегВыражение.ИгнорироватьРегистр = Истина;            
            Совпадения = РегВыражение.НайтиСовпадения(СтрокаОригинал);

            СтруктураМетода.Вставить("Параметры", ПараметрыМетода);
            СтруктураМетода.Вставить("ВозвращаемоеЗначение", ДокВозврат);
            СтруктураМетода.Вставить("Описание", ДокОписание);
            СтруктураМетода.Вставить("Экспорт", ?(Совпадения.Количество()=0, Ложь, Истина));

            МассивМетодов.Добавить(СтруктураМетода);

            ДокПараметры = Неопределено;
            ДокВозврат = Неопределено;
            ДокОписание = "";

        КонецЕсли;
    КонецЦикла;

	Возврат МассивМетодов;

КонецФункции

/// Получает имя модуля из описания библиотеки (lib.config).
/// Ищет файл lib.config в каталоге с модулем и на 1 ур. выше.
///
/// @param ИмяФайла - Строка - Путь к файлу с модулем
/// @return Строка, Неопределено - Имя пакета, если не найдено Неопределено
///
Функция ПолучитьИмяМодуляИзОписанияПакета(ИмяФайла)
    // Сообщить("вошли");
    ФайлМодуля = Новый Файл(ИмяФайла);
// Сообщить("ФайлМодуля: " + ФайлМодуля.ПолноеИмя);

    Путь = ФайлМодуля.Путь;
    Файл = Новый Файл(Путь + "lib.config");
    // Сообщить("0:" + Файл.ПолноеИмя);
    Данные = Неопределено;
    
    Если Файл.Существует() Тогда
        Данные = ПолучитьТекстИзФайла(Путь + "lib.config");
    Иначе
        Файл = Новый Файл(Путь +  "..\" + "lib.config");
        // Сообщить("1:" + Файл.ПолноеИмя);
        Если Файл.Существует() Тогда
            Данные = ПолучитьТекстИзФайла(Файл.ПолноеИмя);
        КонецЕсли;
    КонецЕсли;
// Сообщить("Данные: " + Данные);
    Если Данные = Неопределено Тогда
        Возврат Неопределено;
    КонецЕсли;

    РегВыражение = Новый РегулярноеВыражение("<class name\s*\=\s*""(.*)"" file\s*\=\s*""src\/(.*)""\/>");
    РегВыражение.ИгнорироватьРегистр = Истина;
    РегВыражение.Многострочный = Истина;

    Совпадения = РегВыражение.НайтиСовпадения(Данные);
    // Сообщить("Совпадения: " + Совпадения.Количество());

    Для каждого Сп Из Совпадения Цикл
        СпГр = Сп.Группы;
        // Сообщить("файл: {" + СокрЛП(ФайлМодуля.Имя) + "} {" + СокрЛП(СпГр[2].Значение) + "}");
        Если ВРег(СокрЛП(ФайлМодуля.Имя)) = ВРег(СокрЛП(СпГр[2].Значение)) Тогда
            Возврат СокрЛП(СпГр[1].Значение);
        КонецЕсли
    КонецЦикла;    
	Возврат Неопределено;

КонецФункции // ПолучитьИмяМодуляИзОписанияПакета()

/// Возвращает описание модуля в виде структуры с ключами:
///   - Описание
///   - Автор
///   - Версия
///   - Имя
///
/// @param ИмяФайла - Строка - Путь к файлу с модулем
///
/// @return Структура - с описанием модуля
Функция ПолучитьОписание(ИмяФайла) Экспорт

    Данные = ПолучитьТекстИзФайла(ИмяФайла);
    
    РегВыражение = Новый РегулярноеВыражение("(^\s*\/\/\/[^\/])(.*)");
    РегВыражение.ИгнорироватьРегистр = Истина;
    РегВыражение.Многострочный = Истина;

    Совпадения = РегВыражение.НайтиСовпадения(Данные);

    ОписаниеМодуля = Новый Структура();
    ОписаниеМодуля.Вставить("Описание", "");
    ОписаниеМодуля.Вставить("Автор", "");
    ОписаниеМодуля.Вставить("Версия", "");
    ОписаниеМодуля.Вставить("Имя", "");

    СтрОписание = "";

    Для каждого Сп Из Совпадения Цикл

        СпГр = Сп.Группы;
        СтрДок = СокрЛП(СпГр[2].Значение);

        Если СтрНачинаетсяС(СтрДок, "@Module") Тогда
            Если СокрЛП(Сред(СтрДок,8)) = "#lib.config" Тогда
                ИмяМодуля = ПолучитьИмяМодуляИзОписанияПакета(ИмяФайла);
            Иначе
                ИмяМодуля = СокрЛП(Сред(СтрДок,8));
            КонецЕсли;
            ОписаниеМодуля.Вставить("Имя", ИмяМодуля);
            Прервать;
        ИначеЕсли СтрНачинаетсяС(СтрДок, "@version") Тогда
            ОписаниеМодуля.Вставить("Версия", СокрЛП(Сред(СтрДок,9)));
        ИначеЕсли СтрНачинаетсяС(СтрДок, "@author") Тогда
            ОписаниеМодуля.Вставить("Автор", СокрЛП(Сред(СтрДок,8)));
        Иначе
            СтрОписание  = СтрОписание  + Символы.ВК + Символы.ПС + СтрДок;
        КонецЕсли;

    КонецЦикла;

    ОписаниеМодуля.Вставить("Описание", СокрЛП(СтрОписание));

    Возврат ОписаниеМодуля;

КонецФункции
