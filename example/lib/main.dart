import 'package:flutter/material.dart';
import 'package:units_of_measure_converter/units_of_measure_converter.dart';

void main() {
  runApp(const UcumExampleApp());
}

class UcumExampleApp extends StatelessWidget {
  const UcumExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UCUM Units Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const UcumHomePage(),
    );
  }
}

class UcumHomePage extends StatefulWidget {
  const UcumHomePage({super.key});

  @override
  State<UcumHomePage> createState() => _UcumHomePageState();
}

class _UcumHomePageState extends State<UcumHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UcumService _ucum = UcumService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UCUM Units'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.swap_horiz), text: 'Convert'),
            Tab(icon: Icon(Icons.search), text: 'Lookup'),
            Tab(icon: Icon(Icons.check_circle), text: 'Validate'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ConversionTab(ucum: _ucum),
          LookupTab(ucum: _ucum),
          ValidationTab(ucum: _ucum),
        ],
      ),
    );
  }
}

// ============================================================
// CONVERSION TAB
// ============================================================

class ConversionTab extends StatefulWidget {
  final UcumService ucum;

  const ConversionTab({super.key, required this.ucum});

  @override
  State<ConversionTab> createState() => _ConversionTabState();
}

class _ConversionTabState extends State<ConversionTab> {
  final _valueController = TextEditingController(text: '1');
  final _fromController = TextEditingController(text: 'km');
  final _toController = TextEditingController(text: 'm');
  ConversionResult? _result;

  void _convert() {
    final value = double.tryParse(_valueController.text);
    if (value == null) {
      setState(() {
        _result = ConversionResult(
          success: false,
          fromUnit: _fromController.text,
          toUnit: _toController.text,
          fromValue: 0,
          message: 'Invalid number',
        );
      });
      return;
    }

    setState(() {
      _result = widget.ucum.convertUnitTo(
        _fromController.text,
        value,
        _toController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _valueController,
            decoration: const InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fromController,
                  decoration: const InputDecoration(
                    labelText: 'From Unit',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., km, mg/dL',
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward),
              ),
              Expanded(
                child: TextField(
                  controller: _toController,
                  decoration: const InputDecoration(
                    labelText: 'To Unit',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., m, g/L',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _convert,
            child: const Text('Convert'),
          ),
          const SizedBox(height: 24),
          if (_result != null)
            Card(
              color: _result!.success ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _result!.success ? 'Result' : 'Error',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color:
                                _result!.success ? Colors.green : Colors.red,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (_result!.success)
                      Text(
                        '${_result!.fromValue} ${_result!.fromUnit} = ${_result!.value} ${_result!.toUnit}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      )
                    else
                      Text(
                        _result!.message ?? 'Unknown error',
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'Examples:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _exampleChip('km', 'm'),
              _exampleChip('[lb_av]', 'kg'),
              _exampleChip('Cel', '[degF]'),
              _exampleChip('mg/dL', 'g/L'),
              _exampleChip('km/h', 'm/s'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _exampleChip(String from, String to) {
    return ActionChip(
      label: Text('$from → $to'),
      onPressed: () {
        setState(() {
          _fromController.text = from;
          _toController.text = to;
        });
      },
    );
  }
}

// ============================================================
// LOOKUP TAB
// ============================================================

class LookupTab extends StatefulWidget {
  final UcumService ucum;

  const LookupTab({super.key, required this.ucum});

  @override
  State<LookupTab> createState() => _LookupTabState();
}

class _LookupTabState extends State<LookupTab> {
  final _searchController = TextEditingController();
  List<UcumUnit> _results = [];

  void _search() {
    setState(() {
      _results = widget.ucum.searchUnits(
        _searchController.text,
        maxResults: 50,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search units',
              border: const OutlineInputBorder(),
              hintText: 'Enter unit name, code, or synonym',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _search,
              ),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _results.isEmpty
                ? const Center(
                    child: Text('Search for units by name, code, or synonym'),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final unit = _results[index];
                      return Card(
                        child: ListTile(
                          title: Text(unit.name),
                          subtitle: Text(
                            'Code: ${unit.code} | Property: ${unit.property}',
                          ),
                          trailing: unit.printSymbol != null
                              ? Text(
                                  unit.printSymbol!,
                                  style: Theme.of(context).textTheme.titleLarge,
                                )
                              : null,
                          onTap: () => _showUnitDetails(unit),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showUnitDetails(UcumUnit unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(unit.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Code', unit.code),
              _detailRow('CI Code', unit.ciCode),
              _detailRow('Property', unit.property),
              _detailRow('Print Symbol', unit.printSymbol ?? '-'),
              _detailRow('Metric', unit.isMetric ? 'Yes' : 'No'),
              _detailRow('Base Unit', unit.isBase ? 'Yes' : 'No'),
              _detailRow('Magnitude', unit.magnitude.toString()),
              _detailRow('Dimension', unit.dimension.toString()),
              if (unit.synonyms.isNotEmpty)
                _detailRow('Synonyms', unit.synonyms.join(', ')),
              if (unit.guidance != null)
                _detailRow('Guidance', unit.guidance!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showCommensurableUnits(unit);
            },
            child: const Text('Find Similar Units'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showCommensurableUnits(UcumUnit unit) {
    final commensurable = widget.ucum.commensurablesList(unit.code);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Units convertible to ${unit.code}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: commensurable.length,
            itemBuilder: (context, index) {
              final u = commensurable[index];
              return ListTile(
                title: Text(u.name),
                subtitle: Text(u.code),
                dense: true,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// VALIDATION TAB
// ============================================================

class ValidationTab extends StatefulWidget {
  final UcumService ucum;

  const ValidationTab({super.key, required this.ucum});

  @override
  State<ValidationTab> createState() => _ValidationTabState();
}

class _ValidationTabState extends State<ValidationTab> {
  final _unitController = TextEditingController();
  ValidationResult? _result;
  ParsedUnit? _parsed;

  void _validate() {
    setState(() {
      _result = widget.ucum.validateUnitString(_unitController.text);
      if (_result!.isValid) {
        _parsed = widget.ucum.parseUnit(_unitController.text);
      } else {
        _parsed = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _unitController,
            decoration: InputDecoration(
              labelText: 'Unit String',
              border: const OutlineInputBorder(),
              hintText: 'Enter a UCUM unit expression',
              suffixIcon: IconButton(
                icon: const Icon(Icons.check),
                onPressed: _validate,
              ),
            ),
            onSubmitted: (_) => _validate(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _validate,
            child: const Text('Validate'),
          ),
          const SizedBox(height: 24),
          if (_result != null)
            Card(
              color: _result!.isValid ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _result!.isValid ? Icons.check_circle : Icons.error,
                          color: _result!.isValid ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _result!.isValid ? 'Valid Unit' : 'Invalid Unit',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _result!.isValid
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_result!.isValid && _parsed != null) ...[
                      _infoRow('Normalized Code', _result!.normalizedCode ?? '-'),
                      _infoRow('Magnitude', _parsed!.magnitude.toStringAsExponential(4)),
                      _infoRow('Dimension', _parsed!.dimension.toString()),
                      if (_parsed!.unit != null)
                        _infoRow('Base Unit', _parsed!.unit!.name),
                      if (_parsed!.prefix != null)
                        _infoRow('Prefix', _parsed!.prefix!.name),
                    ],
                    if (!_result!.isValid) ...[
                      for (final msg in _result!.messages)
                        Text(msg, style: const TextStyle(color: Colors.red)),
                      if (_result!.suggestions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Did you mean:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 8,
                          children: _result!.suggestions
                              .map((s) => ActionChip(
                                    label: Text(s),
                                    onPressed: () {
                                      _unitController.text = s;
                                      _validate();
                                    },
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'Try these examples:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _exampleChip('kg'),
              _exampleChip('mg/dL'),
              _exampleChip('m/s2'),
              _exampleChip('kg.m/s2'),
              _exampleChip('[lb_av]'),
              _exampleChip('mmol/L'),
              _exampleChip('invalid'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _exampleChip(String unit) {
    return ActionChip(
      label: Text(unit),
      onPressed: () {
        _unitController.text = unit;
        _validate();
      },
    );
  }
}
