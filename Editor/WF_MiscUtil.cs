/*
 *  The MIT License
 *
 *  Copyright 2018-2021 whiteflare.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 *  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 *  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#if UNITY_EDITOR

using System;
using System.Collections.Generic;
using System.Linq;

namespace UnlitWF
{
    internal static class CollectionUtility
    {
        public static T GetValueOrNull<K, T>(this Dictionary<K, T> dict, K key) where T : class
        {
            T value;
            if (dict.TryGetValue(key, out value))
            {
                return value;
            }
            return null;
        }
    }

    internal class WeakRefCache<T> where T : class
    {
        private readonly List<WeakReference> refs = new List<WeakReference>();

        public bool Contains(T target)
        {
            lock (refs)
            {
                // 終了しているものは全て削除
                refs.RemoveAll(r => !r.IsAlive);

                // 参照が存在しているならばtrue
                foreach (var r in refs)
                {
                    if (r.Target == target)
                    {
                        return true;
                    }
                }
                return false;
            }
        }

        public void Add(T target)
        {
            lock (refs)
            {
                if (Contains(target))
                {
                    return;
                }
                refs.Add(new WeakReference(target));
            }
        }

        public void Remove(T target)
        {
            RemoveAll(target);
        }

        public void RemoveAll(params object[] targets)
        {
            lock (refs)
            {
                // 終了しているものは全て削除
                refs.RemoveAll(r => !r.IsAlive);

                // 一致しているものを全て削除
                refs.RemoveAll(r =>
                {
                    var tgt = r.Target as T;
                    return tgt != null && targets.Contains(tgt);
                });
            }
        }
    }

}

#endif
