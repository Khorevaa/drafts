#Использовать json

Функция ЗаписатьРезультатВФайл(ИмяФайла, Данные)
    Текст = Новый ЗаписьТекста(ИмяФайла, КодировкаТекста.UTF8);
    Текст.Записать(Данные);
    Текст.Закрыть();
КонецФункции // ЗаписатьРезультатВФайл(ИмяФайла,Данные)

/// @param ИмяФайла - Строка - Путь к файлу с модулем, если файл не указан берется основной файл модуля
/// @return Строка - Если файл прочитан
Функция ПолучитьТекстИзФайла(ИмяФайла = "")
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

Функция РаспарситьШаблон(ФайлШаблона, Параметры)

	ДанныеШаблона = ПолучитьТекстИзФайла(ФайлШаблона);
    Для каждого Стр Из Параметры Цикл
		ДанныеШаблона = СтрЗаменить(ДанныеШаблона, "&"+Стр.Ключ+"&", Стр.Значение);
    КонецЦикла;
    ДанныеШаблона = СтрЗаменить(ДанныеШаблона,"&УИД&", Новый УникальныйИдентификатор());
    Возврат ДанныеШаблона;

КонецФункции // РаспарситьШаблон(ФайлШаблона, Параметры)

Функция ПолучитьШапку(Параметры)
    
    ШаблонШапки = "src\templates\report-main-props.xml";
	Возврат РаспарситьШаблон(ШаблонШапки, Параметры);

КонецФункции // ИмяФункции()

Функция ПолучитьРеквизиты(Параметры)

	Реквизиты = "";
	Шаблон = "src\templates\report-attribute.xml";
	Для каждого Реквизит Из Параметры Цикл
        Реквизиты = Реквизиты + РаспарситьШаблон(Шаблон, Реквизит);
    КонецЦикла;

    Возврат Реквизиты;

КонецФункции // ПолучитьРеквизиты()

Процедура СоздатьФайлыПоПравилам(ФайлПравил) Экспорт

	Данные = ПолучитьТекстИзФайла(ФайлПравил);

	Параметры = Новый ПарсерJSON;
	Объект = Параметры.ПрочитатьJSON(Данные);

	Шапка = ПолучитьШапку(Объект);
    Реквизиты = ПолучитьРеквизиты(Объект["Реквизиты"]);

	Результат = Шапка + "<ChildObjects>" + Реквизиты + "</ChildObjects>";

	Сообщить(Результат);

КонецПроцедуры

// СоздатьФайлыПоПравилам("c:\work\scripts\gen-1c-uploads\fixtures\test1.json");