#Использовать ".."
#Использовать asserts

Перем юТест;
Перем Форма;

Процедура Инициализация()
	
КонецПроцедуры

Процедура ОбеспечитьКаталог(Знач Каталог)

	Файл = Новый Файл(Каталог);
	Если Не Файл.Существует() Тогда
		СоздатьКаталог(Каталог);
	ИначеЕсли Не Файл.ЭтоКаталог() Тогда
		ВызватьИсключение "Каталог " + Каталог + " не является каталогом";
	КонецЕсли;

КонецПроцедуры

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


Функция ПолучитьСписокТестов(Тестирование) Экспорт

	юТест = Тестирование;

	СписокТестов = Новый Массив;
	
	// СписокТестов.Добавить("Тест_Должен_СоздатьФайлыКонфигурации");
	СписокТестов.Добавить("Тест_Должен_ПрочитатьСвойства");

	Возврат СписокТестов;

КонецФункции

Процедура Тест_Должен_ПрочитатьСвойства() Экспорт
    Параметры = Новый ПарсерJSON;
	Объект = Параметры.ПрочитатьJSON(ПолучитьТекстИзФайла("src\props.json"));

	Для каждого Стр Из Объект Цикл
        Сообщить(Стр.Ключ + "::" + Стр.Значение);
    КонецЦикла;

КонецПроцедуры


Процедура Тест_Должен_СоздатьФайлыКонфигурации1() Экспорт
    
    СвойстваИмя = Новый Соответствие;
    СвойстваИмя.Вставить("Имя","Созданная");

	КСвойства = Новый Массив;
    КСвойства.Добавить(СвойстваИмя);

	
	

	Спр = Новый Соответствие;
    Спр.Вставить("ТипМетаданных", "Справочник");
    Спр.Вставить("Имя","Справочник3");

    
    Рек1 = Новый Соответствие;
    Рек1.Вставить("Имя","ПолноеИмя");
    Рек1.Вставить("Тип","Строка 100");

    РеквизитыСпр = Новый Массив;
    РеквизитыСпр.Добавить(Рек1);

    Спр.Вставить("Реквизиты",РеквизитыСпр);

	КСостав = Новый Массив;
    КСостав.Добавить(Спр);

	Объект = Новый Соответствие;
    Объект.Вставить("Свойства", КСвойства);
    Объект.Вставить("Состав", КСостав);
    

    Генератор = Новый ГенераторXMLФайлов();

	Генератор.СоздатьФайлыПоПравилам(Спр, "fixtures\Справочник3.xml");

	Генератор.СоздатьФайлКонфигурации("fixtures\new-cf-xml", Объект);

КонецПроцедуры 

Процедура Тест_Должен_СоздатьФайлыКонфигурации() Экспорт
    
	Параметры = Новый ПарсерJSON;
    Генератор = Новый ГенераторXMLФайлов();
	КСостав = Новый Массив;

	Генератор.Конструктор();

    СвойстваИмя = Новый Соответствие;
    СвойстваИмя.Вставить("Имя","Созданная");

	КСвойства = Новый Массив;
    КСвойства.Добавить(СвойстваИмя);

	
    Данные = ПолучитьТекстИзФайла("fixtures\json\Организации.json");
    Объект = Параметры.ПрочитатьJSON(Данные);
    КСостав.Добавить(Объект);
    ОбеспечитьКаталог("fixtures\new-cf-xml\Catalogs\");
	Генератор.СоздатьФайлыПоПравилам(Объект, "fixtures\new-cf-xml\Catalogs\Организации.xml");

    Данные = ПолучитьТекстИзФайла("fixtures\json\Сотрудники.json");
    Объект = Параметры.ПрочитатьJSON(Данные);
    КСостав.Добавить(Объект);
    ОбеспечитьКаталог("fixtures\new-cf-xml\Catalogs\");
	Генератор.СоздатьФайлыПоПравилам(Объект, "fixtures\new-cf-xml\Catalogs\Сотрудники.xml");

    Данные = ПолучитьТекстИзФайла("fixtures\json\Документ1.json");
    Объект = Параметры.ПрочитатьJSON(Данные);
    КСостав.Добавить(Объект);
    ОбеспечитьКаталог("fixtures\new-cf-xml\Documents\");
	Генератор.СоздатьФайлыПоПравилам(Объект, "fixtures\new-cf-xml\Documents\Документ1.xml");

	Объект = Новый Соответствие;
    Объект.Вставить("Свойства", КСвойства);
    Объект.Вставить("Состав", КСостав);

	Генератор.СоздатьФайлКонфигурации("fixtures\new-cf-xml", Объект);

КонецПроцедуры 


//////////////////////////////////////////////////////////////////////////////////////
// Инициализация

Инициализация();