typedef ActionEvent<T> = void Function(T value);
typedef ActionEvent2<T1, T2> = void Function(T1 value, T2);
typedef FunctionEvent<T> = T Function();

typedef BoolComparator<T> = bool Function(T a, T b);
