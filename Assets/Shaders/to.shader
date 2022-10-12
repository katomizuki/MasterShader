Shader "Unlit/to"
{
    Properties
    {
        _MainTex("Texture",2D) = "white" {}
        // セルの列数
        _Column("Column", int) = 8
        // セルの行数
        _Row("Row", int) = 8
        // アニメーションの速度
        _Fps("FPS", float) = 1.0
    }
    SubShader
    {
        Tags 
        {
            "RenderType"="Transparent"    
        }
        // 
        Blend SrcAlpha OnuMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            uint _Row;
            uint _Column;
            uint _Fps;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 col_row = float2(_Column, _Row);
                // UVを各方向のセル数で割る。ここでuvが変化した左下のセルが表示された状態になる。格子状のセルを作る。
                i.uv /= col_row;
                // 経過時間にスケーラーのfpsをかけてその数でセルの総数をわる。（インデックスを経過時間によって変えていく。）(0~インデックス）
                uint index = (_Fps * _Time.y) % (_Column * _Row);
                // 列のインデックス カラム数をインデックスでわったあまり。
                uint column_index = index % _Column;
                // 行のインデックス　index / _Columnで何列目にいるか計算して、それを行で計算する
                uint row_index = _Row - (index / _Column) % _Row - 1;
                // インデックスに行と列のインデックスで作ったfloat2にcol_rowで数値を座標に変換してから加算する
                i.uv += float2(column_index, row_index) / col_row;
                // テキスちゃマッピング
                float4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
