Shader "Unlit/occulusion"
{
    SubShader
    {
        // 通常オブジェクトより背景に近いシェーダーとして設定する
        Tags { "Queue"="geometry-1" }
        // カラーマスクを0にする Ztest LEqual=>) (すでに描画されているオブジェクトと距離が等しいかより近い場合に描画(デフォルト))
        ColorMask 0
        Pass { } 
    }
}
