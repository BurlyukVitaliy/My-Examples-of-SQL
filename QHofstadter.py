"""
Задача 4. Последовательность Хофштадтера
Что нужно сделать
Реализуйте генерацию последовательности Q Хофштадтера (итератором или генератором).
Сама последовательность выглядит так:
Q(n)=Q(n−Q(n−1))+Q(n−Q(n−2))
В итератор (или генератор) передаётся список из двух чисел. Например, QHofstadter([1, 1]) генерирует точную
последовательность Хофштадтера. Если передать значения [1, 2], то последовательность должна немедленно завершиться.

"""
# 1, 1, 2, 3, 3, 4, 5, 5, 6, 6, 6, 8, 8, 8, 10, 9, 10, 11, 11, 12


def refactor(my_list: list) -> None:
    """
    Функция для вывода на печать списка из двух числовых элементов
    преобразует числа в строки, выводит на печать и преобразует назад строки в числа
    для дальнейшего использования
    :param my_list: list
    :return: None
    """
    my_list[0], my_list[1] = str(my_list[0]), str(my_list[1])
    print(', '.join(my_list), end='')
    my_list[0], my_list[1] = int(my_list[0]), int(my_list[1])


class QHofstadter:
    """
    Класс-итератор. Последовательность Хофштадтера
    Реализует генерацию последовательности Q Хофштадтера.

    Args:
        list_num (list): список-последовательность
        limit (int): номер последнего элемента. По умолчанию - 0 (нет ограничений)
    Attributes:
        __counter (int): счетчик элементов последовательности
    """

    def __init__(self, list_num: list, limit: int = 0):
        """
        инициализация класса
        :param list_num: начальный список-последовательность из двух элементов
        :param limit: номер последнего элемента
        установка скрытых атрибутов __counter, __limit, __seq
        """
        self.set_seq(list_num)
        self.set_counter(len(list_num))
        self.set_limit(limit)

    def set_seq(self, list_num):
        """
        сеттер для установки начального списка последовательности
        :param list_num: начальный список
        :type list_num: (list)
        :return: None
        :raise Exception: если список [1, 2], то вызывается исключение
        """
        if list_num[1] == 2 and list_num[0] == 1:
            raise Exception('Некорректные данные')
        else:
            self.__seq = list_num

    def get_seq(self):
        return self.__seq

    def set_counter(self, num):
        self.__counter = num

    def get_counter(self):
        return self.__counter

    def set_limit(self, limit):
        self.__limit = limit

    def get_limit(self):
        return self.__limit

    def __iter__(self):
        return self

    def __next__(self):
        self.set_counter(self.get_counter() + 1)
        next_num = self.get_seq()[self.get_counter() - self.get_seq()[self.get_counter() - 2] - 1] + \
                   self.get_seq()[self.get_counter() - self.get_seq()[self.get_counter() - 3] - 1]
        self.get_seq().append(next_num)
        limit = self.get_limit()
        if limit > 0:
            if self.get_counter() > limit:
                raise StopIteration()
        return next_num


# Исходные данные: список и лимит элементов последовательности
start_list = [1, 1]
my_limit = 20

# основная часть программы
my_q_hofstadter = QHofstadter(start_list, my_limit)
refactor(start_list)
for i_list in my_q_hofstadter:
    print(f', {i_list}', end='')
