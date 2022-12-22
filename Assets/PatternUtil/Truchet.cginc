// 第一引数uv値を入れる。　第二引数noise(0~1)のランダムを入れる。
float2 truchet2D(float2 uv, float index)
{
    // index番号を割り振る(0~1) 真ん中を原点とした形に変更。
    // indexによってuvを変更
    index = frac((index - 0.5) * 2.0);
    if(index > 0.75)
    {
        return float2(1.0, 1.0) - uv;
    }

    if(index > 0.5)
    {
        // そのまま返す
        return float2(uv.x, uv.y);
    }
    if (index > 0.25)
    {
        return 1.0 - float2(1.0 - uv.x, uv.y);
    }
    return uv;
}