part of 'bdd_base.dart';

/// Represents a Gherkin Background block which provides common context
/// and setup steps that execute before each Scenario in a Feature.
///
/// In BDD frameworks, the `Background` allows you to add some context to the
/// scenarios in a single feature. A Background is much like a scenario
/// containing a number of steps, but it runs before each and every scenario
/// setup.
class BddBackground extends BddTerm {
  /// The internal container holding the steps and code blocks for this background.
  final BddFramework _backgroundFramework;

  /// Creates a [BddBackground] that registers itself to [bdd] and delegates its steps to a shared [BddFramework] instance.
  BddBackground(BddFramework bdd, this._backgroundFramework)
      : super(bdd, '', _Variation.term);

  @override
  String spaces(BddConfig config) => config.spaces;

  @override
  String keyword(BddConfig config) => config.keywords.background;

  @override
  String keywordPrefix(BddConfig config) => config.keywordPrefix.background;

  @override
  String keywordSuffix(BddConfig config) => config.keywordSuffix.background;

  @override
  String prefix(BddConfig config) => '';

  @override
  String suffix(BddConfig config) => '';

  @override
  String toString([BddConfig config = BddConfig._default]) {
    var result = spaces(config) +
        keywordPrefix(config) +
        keyword(config) +
        keywordSuffix(config) +
        config.endOfLineChar;
    for (BddTerm term in _backgroundFramework.textTerms) {
      result += term.toString(config) + config.endOfLineChar;
    }
    return result;
  }

  /// This keyword starts a step that sets up the initial context of the
  /// scenario. It's used to describe the state of the world before you begin
  /// the behavior you're specifying in this scenario. For example,
  /// "Given I am logged into the website" sets the scene for the actions that follow.
  BddGiven given(String text) => _backgroundFramework.given(text);

  /// Often used informally in comments within a Gherkin document to provide
  /// additional information, clarifications, or explanations about the scenario
  /// or steps. Comments in Gherkin are usually marked with a hashtag (#) and
  /// are ignored when the tests are executed. A "Note" can be useful for
  /// giving context or explaining the rationale behind a certain test scenario,
  /// making it easier for others to understand the purpose and scope of the test.
  BddGiven note(String text) => BddGiven.note(_backgroundFramework, text);
}
