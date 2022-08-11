"""
Задача 8. Блек-джек
Что нужно сделать

Блек-джек также известен как 21. Суть игры проста: нужно или набрать ровно 21 очко, или набрать очков больше, чем в
руках у дилера, но ни в коем случае не больше 21. Если игрок собирает больше 21, он «сгорает». В случае ничьей игрок
и дилер остаются при своих.
Карты имеют такие «ценовые» значения:
    от двойки до десятки — от 2 до 10 соответственно;
    у туза — 1 или 11 (11 пока общая сумма не больше 21, далее 1);
    у «картинок» (король, дама, валет) — 10.
Напишите программу, которая вначале случайным образом выдаёт пользователю и компьютеру по две карты и затем запрашивает
у пользователя действие: взять карту или остановиться. На экран должна выдаваться информация о руке пользователя.
После того как игрок останавливается, выведите на экран победителя.
Представление карты реализуйте с помощью класса.
Дополнительно: сделайте так, чтобы карты не могли повторяться.
Ваши классы в этой задаче могут выглядеть так:
class Card:
    #  Карта, у которой есть значения
    #   - масть
    #   - ранг/принадлежность 2, 3, 4, 5, 6, 7 и так далее
class Deck:
    #  Колода создаёт у себя объекты карт
class Player:
    #  Игрок, у которого есть имя и какие-то карты на руках
"""


import random


def count_point(subj: ('Dealer', 'Player')) -> int:
    """
    The function determines the number of points a player or dealer
    has depending on the cards in their hand
    :param subj: ('Dealer', 'Player')
    :return: (int)
    """

    point = 0
    is_there_an_ace = False
    is_there_an_joker = False

    for i_card in subj.list_cards:
        point += i_card.rang
        if i_card.name[0:1] == 'Т':
            is_there_an_ace = True
        if i_card.name[0:1] == 'J':
            is_there_an_joker = True

    # if ace, then 1 or 11 points depending on the situation
    if is_there_an_ace:
        point += 10  # 1 point is already in the rank
        if point > 21:
            point -= 10

    # if a joker, then replaces any card. Points can be from 1 to 11 depending on the situation.
    if is_there_an_joker:
        add_point = 0
        if 0 < 21 - point <= 11:
            add_point = 21 - point
        elif 21 - point > 0:
            add_point = 11
        point += add_point

    # if there are more than 21 points, then bust, points are reset to zero
    if point > 21:
        point = 0

    return point


class Card:
    """ Class Playing card from the deck """

    def __init__(self, suit: str, rang: int, additional_feature: str) -> 'Card':
        """
        Initialization function
        :param suit: (str)
        :param rang: (int) 2 >= rang <= 10
        :param additional_feature: (str)
        """
        self.suit = suit
        self.rang = rang
        self.name = additional_feature+suit

    def __str__(self):
        return self.name

    def __repr__(self):
        return repr(self.name)


class Deck:
    """ Class Deck """
    def __init__(self) -> 'Deck':
        """ Initialization function
        A deck of cards is formed based on ranks, pictures, jokers
        """

        self.suits = ['♥', '♦', '♣', '♠']
        self.pictures = ['В', 'Д', 'К']
        self.list_cards = list()
        for i_suit in self.suits:
            for i_simple_card in range(1, 11):
                if i_simple_card == 1:
                    self.list_cards.append(Card(i_suit, i_simple_card, 'Т'))
                else:
                    self.list_cards.append(Card(i_suit, i_simple_card, str(i_simple_card)))
            for i_pictures_card in self.pictures:
                self.list_cards.append(Card(i_suit, 10, i_pictures_card))
            if i_suit in ['♣', '♦']:
                self.list_cards.append(Card(i_suit, 0, 'J'))

    def __str__(self):
        """
        The function of displaying a deck of cards on the screen line by line by suit
        :return: str
        """

        list_card_suit = [[ind_card.name
                          for ind_card in self.list_cards if ind_suit == ind_card.suit
                           ]
                          for ind_suit in self.suits
                          ]
        string = ''
        for i_list_card in list_card_suit:
            string += '  '.join(i_list_card)+'\n'
        return string


class Player:
    """ Class Player  """

    def __init__(self, name: str) -> 'Player':
        """
        Initialization function
        :param name: not used yet
        :list_cards: (list) list of cards in the player's hand
        """

        self.name = name
        self.list_cards = list()
        print('Приветствую Вас')

    def print_arm(self):
        """
        The function shows the cards in the player's hand
        """

        print('У вас: {}'.format(' '.join([i_card.name for i_card in self.list_cards])))

    def __repr__(self):
        return repr(self.name)


class Dealer:
    """ Class Dealer. Dealing cards from the deck, announcement of the winner """
    def __init__(self, deck_card: 'Deck') -> 'Dealer':
        """
        Initialization function
        :param deck_card (Deck):
        :list_cards: (list) list of cards in the Dealer's hand
        """

        self.list_cards = list()
        self.deck = deck_card

    def add_card(self, subj: ('Dealer', 'Player')) -> None:
        """
        Handing over the card
        :param subj: ('Dealer' or 'Player')
        :return: (None)
        """

        rand_num = random.randint(0, len(self.deck.list_cards)-1)
        subj.list_cards.append(self.deck.list_cards.pop(rand_num))

    def card_distribution(self, card_player: ('Dealer', 'Player')) -> None:
        """
        The function of initialing distribution of two cards in hand
        :param card_player: ('Dealer' or 'Player')
        :return: None
        """

        for _ in range(2):
            self.add_card(self)
            self.add_card(card_player)

    def print_arm(self):
        """
        The function shows the cards in the dealer's hand
        """

        print('У дилера: {}'.format(' '.join([i_card.name for i_card in self.list_cards])))

    def determine_the_winner(self, card_player: ('Dealer', 'Player')) -> ('Dealer', 'Player'):
        """
        The function of determining the winner in the game
        :param card_player: ('Dealer' or 'Player')
        :return: ('Dealer' or 'Player')
        """

        self_point = count_point(self)
        player_point = count_point(card_player)
        if self_point < player_point:
            winner = card_player
        elif self_point > player_point:
            winner = self
        else:
            winner = None
        return winner

    def print_winner(self, card_player: ('Dealer', 'Player')) -> None:
        """
        The function shows the winner of the game
        :param card_player:
        :return: None
        """

        winner = self.determine_the_winner(card_player)
        if winner:
            if winner == self:
                print('Победитель: ', winner)
            else:
                print('Вы победитель!')
        else:
            print('Ничья')

    def __repr__(self):
        return repr('Дилер')


deck = Deck()
# print(deck)
# print(deck.list_cards)
# player = Player(input('Введите свое имя: '))
player = Player('Игрок')
action = input('Введите \'Да\', если хотите посмотреть колоду: ')
if action.lower() == 'да':
    print(deck)
dealer = Dealer(deck)
print('Сдается по две карты')
dealer.card_distribution(player)
player.print_arm()
# dealer.print_arm()
# print(deck.list_cards)

while True:
    action = input('Введите \'Да\', если хотите взять карту: ')
    if action.lower() == 'да':
        print('Держите еще карту\n')
        dealer.add_card(player)
        player.print_arm()
    else:
        print('\nИгра окончена\n')
        break

dealer.print_winner(player)
player.print_arm()
dealer.print_arm()


