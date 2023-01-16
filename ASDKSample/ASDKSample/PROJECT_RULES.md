Общие правила оформления кода:

Наш идеальный сценарий:
То к чему мы стремимся, это когда при открытии любого файла с кодом, было бы не возможно понять ты его написал или нет.

1) Для всех классов, для которых не требуется наследование, добавляем final.

Пример:
final class SomeClass {}

2) Если блок else у guard простой и не требует никакой логики, то пишем его в одну строчку.

Пример:
guard let self = self else { return }

Допустимое написание, если появляется вызов короткого метода:
guard let url = URL(string: "some://url?text") else { completion(false); return }

3) В кложурах не юзаем unowned, всегда используем weak.

Пример:
let someClosure = { [weak self] in
    ...
}

4) Весь код группируем при помощи марок "// MARK: -"

Cписок основных и обязательных:
// MARK: - Dependencies
// MARK: - Properties
// MARK: - Initialization
// MARK: - Overrides
// MARK: - Actions
// MARK: - Private methods
// MARK: - Public methods

Если properties относятся к какому либо протоколу то отделяем их с припиской названия этого протокола:
// MARK: - PullableContainerContent Properties

5) Так же код разделяем при помощи extension и обязательной марки к нему, с аналогичным названием:

Пример:

// MARK: - UITableViewDataSource

extension SomeClass: UITableViewDataSource {}

// MARK: - Actions

extension SomeClass {
    @objc private someAction(_ sender: UIButton) {}
}

// MARK: - Private methods

extension SomeClass {
    private func someMethod() {}
}

6) Стараемся писать само документируемый код (что бы по названию метода, свойства, названию класса и тд было понятно для чего это и что оно делает), если это не очевидно и могут возникнуть трудности у того кто будет это смотреть / изменять / дополнять, то обязательно оставляем комментарии. Можно оставить комментарий ко всему модулю над вью контроллером этого модуля, для понимания как устроен модуль в целом и что в нем особенного.

Пример:

let closeButton: UIButton!
func closeButtonAction(_ sender: UIButton) {}

7) Для констант делаем приватный extension с нужным типом данных.
    Все константы располагаются в самом низу файла под маркой "// MARK: - Constants":
    
Пример:

// MARK: - Constants

private extension CGFloat {
    static let logoImageSide: CGFloat = 40
    static let logoImageVerticalOffset: CGFloat = 8
    static let logoImageLeftOffset: CGFloat = 16
}

Если уж слишком много разношёрстных констант, то можно создать единый enum, но приоритет за extension к конкретному типу!

// MARK: - Constants

private enum Constants {
    static let anchorInset: CGFloat = 24
    static let defaultSize = CGSize(width: UIScreen.main.bounds.width - (2 * 16), height: 64)
    static let insets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
}

8) Все констрейнты пишем нативно, без использования сторонних библиотек и не делаем удобные обертки или extension к ним.
    Установка констрейнтов происходит в специально созданных методах с соотвествующими названиями, либо обобщенные, либо
    для конкретной вьюхи (setupViewsConstraints / setupTableView):

Пример:

private func setupViewsConstraints() {
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    logoImageView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
        logoImageView.widthAnchor.constraint(equalToConstant: .logoImageSide),
        logoImageView.heightAnchor.constraint(equalToConstant: .logoImageSide),
        logoImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: .logoImageLeftOffset),
        logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .logoImageVerticalOffset),
        logoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.logoImageVerticalOffset),

        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        nameLabel.leftAnchor.constraint(equalTo: logoImageView.rightAnchor, constant: .nameLeftInset),
        nameLabel.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -.nameRightInset),
    ])
}

9) Стараемся давать typealias всем кложурам, которые встречаются в каком либо сервисе или где либо еще, более чем один раз.
    Если кложура встречается один раз, то добавление typealias по желанию:

Пример:
typealias SBPBanksServiceLoadBanksCompletion = (Result<[SBPBank], Error>) -> Void

Для часто повторяющихся выносим их в файл Typealiases.swift:
typealias VoidBlock = () -> Void

10) Стараемся писать более понятные конструкции кода:

Пример не удачной конструкции:

func performOnMain(_ closure: @escaping () -> Void) {
    guard !Thread.isMainThread else {
        closure()
        return
    }

    DispatchQueue.main.async(execute: closure)
}

В данном пример используется guard да еще и с реверсом Bool(го) значения, в данном кейсе это усложняет понимание написанного.
Намного логичнее тут зашел бы if: 

func performOnMain(_ closure: @escaping () -> Void) {
    if Thread.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async(execute: closure)
    }
}

Но так как тут в скоупах ифа короткие односторчные команды, то в идеале лучше так:

func performOnMain(_ closure: @escaping () -> Void) {
    Thread.isMainThread ? closure() : DispatchQueue.main.async(execute: closure)
}

Cтараемся думать об этом и не засовывать везде guard, когда if прекрасно подходит.

11) Названия UIных компонентов всегда должны заканчиваться в соотвествии с из типом:

Пример:
var nameLabel: UILabel
var descriptionLabel: UILabel
var speedSlider: UISlider
var closeButton: UIButton 

12) Названия методов используемых как action для всех UIControl или жестов, должны называться как называется соответсвующий
UIный элемент + Action:

Пример:
func closeButtonAction(_ sender: UIButton) {}
func tapGestureAction(_ sender: UITapGestureRecognizer) {}

13) Использование xib(ов) и storyboard(ов) запрещено !!!

14) Струкрута модуля (порядок расположения, название папок и файлов, должно быть таким):
 Папки сверху вниз: Assembly -> Services (если есть, на этом месте могут быть другие необходимые папки, необходимые для работы модуля) -> Views (Cells, View и другие вьюхи используемые в модуле) -> Presenter -> Router (если нужен)

В папке файл протокола всегда на первом месте.

(В примере, название без ‘-’ это папка, c ‘-’ это файл)

Пример:

Some
    Assembly
        - ISomeAssembly    
        - SomeAssembly
    Services (опционально)
        SomeService
            - ISomeService
            - SomeService
    Views
        Cells (опционально)
            SomeCell
                Assembly
                    - ISomeCellPresenterAssembly
                    - SomeCellPresenterAssembly
                Cell
                    - ISomeCellInput
                    - SomeCell
                Presenter
                    - ISomeCellOutput
                    - SomeCellPresenter
        View
            - ISomeViewInput
            - SomeViewController
    Presenter
        - ISomeModuleInput (опционально)
        - ISomeViewOutput
        - SomePresenter
    Router (опционально)
        - ISomeRouterInput
        - SomeRouter
        
15) Если ячейка не тупая и у нее появляется хоть какая то логика связанная с ней, то добавляем ей презентер и если требуется 
Assembly, для примера смотрим SBPBankCellNew.

16) Стараемся следить за желтыми варнингами и не плодить новых.

17) public и open добавляем в исключительных случаях, там где они реально нужны.

18) Все текста берем из Loc

Пример:
let alertTitle = Loc.Sbp.Error.title

19) Все картинки берем из Asset

Пример:
let editImage = Asset.Icons.editing.image

20) Все цвета берем из ASDKColors

Пример:
let textColor = ASDKColors.Text.primary.color

21) Презентер модуля общается исключительно с одной вьюхой, не допустимы сокращения передачи событий из какой либо
вьюхи в обход главной вьюхи модуля. То есть, все вьюхи модуля общаются исключительно с главной вьюхой модуля.
