#ifndef EXTENSION_NOISE_UTIL
#define EXTENSION_NOISE_UTIL

#include "UnityCG.cginc"

fixed2 TRANSFORM_NOISE_TEX(fixed2 uv, fixed4 tilingOffset, fixed4 sizeScroll)
{
   // タイリング、オフセットを考慮したuv値を計算している　uvにタイリング値(x,y)をかけてあげる
   // テクスチャサイズをかける　それにオフセットを足す。
   // uv * sizeScroll.xy =>
   // 
   uv = uv * tilingOffset.xy * sizeScroll.xy + tilingOffset.zw;
   // 実際にuvスクロールをする
   // タイリングに合わせた相対速度でスクロール
   // tilingOffsetのx sizeScrollのuvスクロール(テクスチャサイズ）
   uv += fixed2(sizeScroll.z * tilingOffset.x, -sizeScroll.w * tilingOffset.y) * _Time.y;
   return uv;
}

fixed rand(fixed2 uv, fixed2 size) {
   uv = frac(uv / size);
   return frac(sin(dot(frac(uv / size), fixed2(12.9898, 78.233))) * 43758.5453) * 0.99999;
}

// 勾配ベクトル
fixed2 gradientVector(fixed2 uv, fixed2 size) {
   uv = frac(uv / size);
   uv = fixed2(dot(frac(uv / size), fixed2(127.1, 311.7)), dot(frac(uv / size), fixed2(269.5, 183.3)));
   return -1.0 + 2.0 * frac(sin(uv) * 43758.5453123);
}

fixed2 bilinear(fixed f0, fixed f1, fixed f2, fixed f3, fixed fx, fixed fy) {
   return lerp(lerp(f0, f1, fx), lerp(f2, f3, fx), fy);
}

fixed fade(fixed t) {
   return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

fixed blockNoise(fixed2 uv, fixed2 size) {
   return rand(floor(uv), size);
}

fixed valueNoiseOne(fixed2 uv, fixed2 size) {
   fixed2 p = floor(uv);
   fixed2 f = frac(uv);
   float f00 = rand(p + fixed2(0, 0), size);
   float f10 = rand(p + fixed2(1, 0), size);
   float f01 = rand(p + fixed2(0, 1), size);
   float f11 = rand(p + fixed2(1, 1), size);
   return bilinear( f00, f10, f01, f11, fade(f.x), fade(f.y) );
}

fixed valueNoise(fixed2 uv, fixed2 size) {
   fixed f = 0;
   f += valueNoiseOne(uv *  2, size) / 2;
   f += valueNoiseOne(uv *  4, size) / 4;
   f += valueNoiseOne(uv *  8, size) / 8;
   f += valueNoiseOne(uv * 16, size) / 16;
   f += valueNoiseOne(uv * 32, size) / 32;
   return f;
}

fixed perlinNoiseOne(fixed2 uv, fixed2 size) {
   fixed2 p = floor(uv);
   fixed2 f = frac(uv);

   fixed d00 = dot(gradientVector(p + fixed2(0, 0), size), f - fixed2(0, 0));
   fixed d10 = dot(gradientVector(p + fixed2(1, 0), size), f - fixed2(1, 0));
   fixed d01 = dot(gradientVector(p + fixed2(0, 1), size), f - fixed2(0, 1));
   fixed d11 = dot(gradientVector(p + fixed2(1, 1), size), f - fixed2(1, 1));
   return bilinear(d00, d10, d01, d11, fade(f.x), fade(f.y)) + 0.5f;
}

fixed perlinNoise(fixed2 uv, fixed2 size) {
   fixed f = 0;
   f += perlinNoiseOne(uv *  2, size) / 2;
   f += perlinNoiseOne(uv *  4, size) / 4;
   f += perlinNoiseOne(uv *  8, size) / 8;
   f += perlinNoiseOne(uv * 16, size) / 16;
   f += perlinNoiseOne(uv * 32, size) / 32;
   return f;
}

fixed3 normalNoise(fixed2 uv, fixed2 size) {
   fixed3 result = fixed3(perlinNoise(uv.xy, size),
                          perlinNoise(uv.xy + fixed2(1, 1), size),
                          1.0);
   return result;
}

#endif